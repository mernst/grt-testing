all: jarfiles/jacocoagent.jar jarfiles/randoop-all-4.3.2.jar

jarfiles/jacocoagent.jar:
	mkdir -p jarfiles
	cd jarfiles && find -type f -exec rm {} +
	cd jarfiles && wget -O jacoco-0.8.10.zip https://search.maven.org/remotecontent?filepath=org/jacoco/jacoco/0.8.10/jacoco-0.8.10.zip
	cd jarfiles && unzip jacoco-0.8.10.zip lib/jacocoagent.jar


jarfiles/randoop-all-4.3.2.jar:
	mkdir -p jarfiles
	cd jarfiles && wget https://github.com/randoop/randoop/releases/download/v4.3.2/randoop-all-4.3.2.jar
