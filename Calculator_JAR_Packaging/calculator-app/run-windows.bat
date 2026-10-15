@echo off
setlocal
cd /d "%~dp0"
if not exist "lib\math-lib.jar" (
    echo Thieu lib\math-lib.jar
    exit /b 1
)
if not exist "target\classes" mkdir "target\classes"
javac --release 17 -encoding UTF-8 -cp "lib\math-lib.jar" -d "target\classes" "src\main\java\com\codegym\Main.java"
if errorlevel 1 exit /b 1
java -cp "target\classes;lib\math-lib.jar" com.codegym.Main
endlocal
