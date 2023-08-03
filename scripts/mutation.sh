#!/bin/bash

#Link to the major directory
MAJOR_HOME="../major/"

#Link to the randoop jar
RANDOOP_JAR="/mnt/c/Users/varun/downloads/randoop-4.3.2/randoop-4.3.2/randoop-all-4.3.2.jar"

#Link to src files containing the project (make sure to also "src" property in .xml file)
PROJECT_SRC="/mnt/c/Users/varun/Downloads/commons-cli-1.2-src/commons-cli-1.2-src/src/java"

#Link to jacoco agent jar
JACOCO_JAR="/mnt/c/Users/varun/Downloads/jacoco-0.8.10/lib/jacocoagent.jar"

#Seconds per class
SECONDS_CLASS="2"

#Number of times to run experiments (10 in GRT paper)
NUM_LOOP=2

rm -rf test
rm info.txt
mkdir test
touch info.txt

echo "Using Randoop to generate tests"
echo
find $PROJECT_SRC -name '*.java' -print0 | xargs -0 javac
find $PROJECT_SRC -type f -name "*.class" -printf "%P\n" | sed 's/\//./g' | sed 's/.class$//' > $PROJECT_SRC/myclasses.txt

NUM_CLASSES=$(wc -l < $PROJECT_SRC/myclasses.txt)
TIME_LIMIT=$((NUM_CLASSES * SECONDS_CLASS))

for i in $(seq 1 $NUM_LOOP)
do
    # echo "Using Bloodhound"
    # echo
    # java -classpath "$PROJECT_SRC:$RANDOOP_JAR" -Xbootclasspath/a:$JACOCO_JAR -javaagent:$JACOCO_JAR randoop.main.Main gentests --classlist="$PROJECT_SRC/myclasses.txt" --time-limit=$TIME_LIMIT --method-selection=BLOODHOUND --junit-output-dir="$PWD/test"

    # echo "Using Orienteering"
    # echo
    # java -classpath "$PROJECT_SRC:$RANDOOP_JAR" randoop.main.Main gentests --classlist="$PROJECT_SRC/myclasses.txt" --time-limit=$TIME_LIMIT --input-selection=ORIENTEERING --junit-output-dir="$PWD/test"

    # echo "Using Bloodhound and Orienteering"
    # echo
    # java -classpath "$PROJECT_SRC:$RANDOOP_JAR" -Xbootclasspath/a:$JACOCO_JAR -javaagent:$JACOCO_JAR randoop.main.Main gentests --classlist="$PROJECT_SRC/myclasses.txt" --time-limit=$TIME_LIMIT --input-selection-ORIENTEERING --method-selection=BLOODHOUND --junit-output-dir="$PWD/test"

    echo "Using Baseline Randoop"
    echo
    java -classpath "$PROJECT_SRC:$RANDOOP_JAR" randoop.main.Main gentests --classlist="$PROJECT_SRC/myclasses.txt" --time-limit=$TIME_LIMIT --junit-output-dir="$PWD/test"

    echo    
    echo "Compiling and mutating project"
    echo "(ant -Dmutator=\"=mml:\$MAJOR_HOME/mml/all.mml.bin\" clean compile)"
    echo
    $MAJOR_HOME/bin/ant -Dmutator="mml:$MAJOR_HOME/mml/all.mml.bin" clean compile
    
    echo
    echo "Compiling tests"
    echo "(ant compile.tests)"
    echo
    $MAJOR_HOME/bin/ant compile.tests

    echo
    echo "Run tests with mutation analysis"
    echo "(ant mutation.test)"
    $MAJOR_HOME/bin/ant mutation.test

    cat summary.csv >> info.txt

    rm "$PROJECT_SRC/myclasses.txt"
    
done


