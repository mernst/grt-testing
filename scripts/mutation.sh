#!/bin/bash

#This script uses mutation testing with Randoop generating the test suites. Different
#test suites can be generated with Bloodhound, Orienteering, neither (baseline), or both.
#Mutation testing is used on projects provided in table 2 of the GRT paper.

#This script will create and put Randoop's test suites in a "test" subdirectory. 
#Compiled tests and code will be stored in a "bin" subdirectory.
#The script will generate various mutants of the source project using Major and run these tests on those mutants.

#Finally, each experiment can run a given amount of times and a given amount of seconds per class. 
#Each iteration will be logged to a file "info.txt".
#See "repoinstructions.txt" for more instructions on how to successfully run this script and reproduce my results.

make

#Link to the major directory
MAJOR_HOME="../major/"
MAJOR_HOME=$(realpath "$MAJOR_HOME")

#Link to the randoop jar
RANDOOP_JAR="jarfiles/randoop-all-4.3.2.jar"
RANDOOP_JAR=$(realpath "$RANDOOP_JAR")

#Link to src files containing the project (must be Gradle, Maven, or a Make project)
PROJECT_SRC="/mnt/c/Users/varun/Downloads/commons-cli-1.2-src/commons-cli-1.2-src"

#Link to java src files (exclude subdirectory w/ test files)
JAVA_SRC_FILES="/mnt/c/Users/varun/Downloads/commons-cli-1.2-src/commons-cli-1.2-src/src/java"

#Link to jacoco agent jar
JACOCO_JAR="jarfiles/lib/jacocoagent.jar"
JACOCO_JAR=$(realpath "$JACOCO_JAR")

#Link to original directory
CURR_DIR=$(pwd)
CURR_DIR=$(realpath "$CURR_DIR")

#Seconds per class
SECONDS_CLASS="2"

#Number of times to run experiments (10 in GRT paper)
NUM_LOOP=2

rm info.txt
touch info.txt
rm -rf $PROJECT_SRC/target #Specific to Apache Commons Cli v 1.2 and its pom.xml file -- will have to generalize in the future

echo "Using Randoop to generate tests"
echo
cd $PROJECT_SRC && $CURR_DIR/compile-project.sh && cd $CURR_DIR

PROJECT_SRC="$PROJECT_SRC/target/classes" #Again, specific to Apache Commons Cli v 1.2 and its pom.xml file -- will have to generalize in the future

find $PROJECT_SRC -type f -name "*.class" -printf "%P\n" | sed 's/\//./g' | sed 's/.class$//' > $PROJECT_SRC/myclasses.txt

NUM_CLASSES=$(wc -l < $PROJECT_SRC/myclasses.txt)
TIME_LIMIT=$((NUM_CLASSES * SECONDS_CLASS))

#Variable that stores command line inputs common among all commands
CLI_INPUTS="java -Xbootclasspath/a:$JACOCO_JAR -javaagent:$JACOCO_JAR -classpath $PROJECT_SRC:$RANDOOP_JAR randoop.main.Main gentests --classlist=$PROJECT_SRC/myclasses.txt --time-limit=$TIME_LIMIT"

for i in $(seq 1 $NUM_LOOP)
do
    rm -rf test*

    echo "Using Bloodhound"
    echo
    mkdir testBloodhound
    TEST_DIRECTORY="testBloodhound"
    $CLI_INPUTS --method-selection=BLOODHOUND --junit-output-dir="$PWD/testBloodhound"

    # echo "Using Orienteering"
    # echo
    # mkdir testOrienteering
    # TEST_DIRECTORY="testOrienteering"
    # $CLI_INPUTS --input-selection=ORIENTEERING --junit-output-dir="$PWD/testOrienteering"

    # echo "Using Bloodhound and Orienteering"
    # echo
    # mkdir testBloodhoundOrienteering
    # TEST_DIRECTORY="testBloodhoundOrienteering"
    # $CLI_INPUTS --input-selection=ORIENTEERING --method-selection=BLOODHOUND --junit-output-dir="$PWD/testBloodhoundOrienteering"

    # echo "Using Baseline Randoop"
    # echo
    # mkdir testBaseline
    # TEST_DIRECTORY="testBaseline"
    # $CLI_INPUTS --junit-output-dir="$PWD/testBaseline"

    echo    
    echo "Compiling and mutating project"
    echo "(ant -Dmutator=\"=mml:\$MAJOR_HOME/mml/all.mml.bin\" clean compile)"
    echo
    $MAJOR_HOME/bin/ant -Dmutator="mml:$MAJOR_HOME/mml/all.mml.bin" -Dsrc="$JAVA_SRC_FILES" clean compile
    
    echo
    echo "Compiling tests"
    echo "(ant compile.tests)"
    echo
    $MAJOR_HOME/bin/ant -Dtest="$TEST_DIRECTORY" -Dsrc="$JAVA_SRC_FILES" compile.tests

    echo
    echo "Run tests with mutation analysis"
    echo "(ant mutation.test)"
    $MAJOR_HOME/bin/ant -Dtest="$TEST_DIRECTORY" mutation.test

    cat summary.csv >> info.txt
   
done
