#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
mkdir -p target/manual-tests
javac -encoding UTF-8 -d target/manual-tests src/main/java/com/codegym/CurrencyCalculator.java src/test/java/com/codegym/CurrencyCalculatorTest.java
java -cp target/manual-tests com.codegym.CurrencyCalculatorTest
