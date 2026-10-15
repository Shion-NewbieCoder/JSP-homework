#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
mkdir -p target/classes
javac --release 17 -encoding UTF-8 -cp "lib/quadratic-equation-lib.jar" -d "target/classes" "src/main/java/com/codegym/app/Main.java"
java -Dfile.encoding=UTF-8 -cp "target/classes:lib/quadratic-equation-lib.jar" com.codegym.app.Main "$@"
