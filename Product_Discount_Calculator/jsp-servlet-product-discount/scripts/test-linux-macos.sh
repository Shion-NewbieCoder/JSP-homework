#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p target/self-test
javac --release 17 -encoding UTF-8 -d target/self-test \
  src/main/java/com/codegym/service/DiscountCalculator.java \
  src/main/java/com/codegym/service/DiscountResult.java \
  src/test/java/com/codegym/service/DiscountCalculatorSelfTest.java
java -cp target/self-test com.codegym.service.DiscountCalculatorSelfTest
