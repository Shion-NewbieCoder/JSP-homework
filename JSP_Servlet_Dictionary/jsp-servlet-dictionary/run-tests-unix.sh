#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p .test-build
javac --release 17 -encoding UTF-8 -d .test-build \
  src/main/java/com/codegym/DictionaryService.java \
  src/main/java/com/codegym/HtmlUtil.java \
  src/test/java/com/codegym/DictionaryServiceTest.java
java -cp .test-build com.codegym.DictionaryServiceTest
