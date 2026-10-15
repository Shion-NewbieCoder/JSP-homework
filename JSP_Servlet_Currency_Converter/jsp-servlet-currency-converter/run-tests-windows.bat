@echo off
setlocal
cd /d "%~dp0"
if not exist target\manual-tests mkdir target\manual-tests
javac -encoding UTF-8 -d target\manual-tests src\main\java\com\codegym\CurrencyCalculator.java src\test\java\com\codegym\CurrencyCalculatorTest.java
if errorlevel 1 exit /b 1
java -cp target\manual-tests com.codegym.CurrencyCalculatorTest
