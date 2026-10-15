@echo off
setlocal
cd /d "%~dp0"
if not exist target\test-classes mkdir target\test-classes
javac --release 17 -encoding UTF-8 -cp "lib\quadratic-equation-lib.jar" -d "target\test-classes" "tests\QuadraticEquationSelfTest.java"
if errorlevel 1 exit /b 1
java -cp "target\test-classes;lib\quadratic-equation-lib.jar" QuadraticEquationSelfTest
