#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p target/classes
javac --release 17 -encoding UTF-8 -cp lib/math-lib.jar -d target/classes src/main/java/com/codegym/Main.java
java -cp 'target/classes:lib/math-lib.jar' com.codegym.Main
