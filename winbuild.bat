@echo off
nimrod c -l=-lmarkdown -l=-L$PWD/vendor hastyscribe.nim
cp hastyscribe.exe build/win/hastyscribe.exe
