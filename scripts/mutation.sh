#!/bin/sh

#Link to the major directory
MAJOR_HOME="../major/"

#Link to the randoop jar
RANDOOP_JAR="/mnt/c/Users/varun/downloads/randoop-4.3.2/randoop-4.3.2/randoop-all-4.3.2.jar"

#Link to src files containing the project
PROJECT_SRC="/mnt/c/Users/varun/Downloads/commons-cli-master/commons-cli-master/src/main/java"

rm -rf test
mkdir test

echo "Using Randoop to generate tests"
echo
find $PROJECT_SRC -name 'test' -prune -o -name '*.java' -print0 | xargs -0 javac
find $PROJECT_SRC -type f -name "*.class" -not -path "$PROJECT_SRC/test/*" -printf "%P\n" | sed 's/\//./g' | sed 's/.class$//' > $PROJECT_SRC/myclasses.txt
java -classpath "$PROJECT_SRC:$RANDOOP_JAR" randoop.main.Main gentests --classlist="$PROJECT_SRC/myclasses.txt" --time-limit=90 --junit-output-dir="$PWD/test"

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


