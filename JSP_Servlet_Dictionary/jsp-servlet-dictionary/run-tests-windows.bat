@echo off
setlocal
cd /d "%~dp0"
if not exist ".test-build" mkdir ".test-build"
javac --release 17 -encoding UTF-8 -d ".test-build" src\main\java\com\codegym\DictionaryService.java src\main\java\com\codegym\HtmlUtil.java src\test\java\com\codegym\DictionaryServiceTest.java
if errorlevel 1 exit /b 1
java -cp ".test-build" com.codegym.DictionaryServiceTest
exit /b %errorlevel%
