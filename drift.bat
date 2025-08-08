@echo off
cls

echo Generating Database Files...
dart run build_runner build --delete-conflicting-outputs