@echo off
setlocal
cd /d "%~dp0.."
if not exist "target\self-test" mkdir "target\self-test"
javac --release 17 -encoding UTF-8 -d "target\self-test" "src\main\java\com\codegym\service\DiscountCalculator.java" "src\main\java\com\codegym\service\DiscountResult.java" "src\test\java\com\codegym\service\DiscountCalculatorSelfTest.java"
if errorlevel 1 exit /b 1
java -cp "target\self-test" com.codegym.service.DiscountCalculatorSelfTest
