#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
mkdir -p target/test-classes
javac --release 17 -encoding UTF-8 -cp "lib/quadratic-equation-lib.jar" -d "target/test-classes" tests/QuadraticEquationSelfTest.java
java -cp "target/test-classes:lib/quadratic-equation-lib.jar" QuadraticEquationSelfTest
