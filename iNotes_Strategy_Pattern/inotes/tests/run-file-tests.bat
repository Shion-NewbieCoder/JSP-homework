@echo off
setlocal
cd /d "%~dp0.."
if not exist "build-test" mkdir "build-test"
javac --release 17 -encoding UTF-8 -d build-test src\main\java\com\codegym\model\*.java src\main\java\com\codegym\strategy\*.java src\main\java\com\codegym\service\*.java tests\InotesTest.java
if errorlevel 1 exit /b 1
java -ea -cp build-test InotesTest
if errorlevel 1 exit /b 1
endlocal
