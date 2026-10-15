@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
if not exist target\classes mkdir target\classes
javac --release 17 -encoding UTF-8 -cp "lib\quadratic-equation-lib.jar" -d "target\classes" "src\main\java\com\codegym\app\Main.java"
if errorlevel 1 exit /b 1
java -Dfile.encoding=UTF-8 -cp "target\classes;lib\quadratic-equation-lib.jar" com.codegym.app.Main %*
