@echo off
nimrod c -l=-lmarkdown -l=-L%~dp0\vendor hastyscribe.nim
cp hastyscribe.exe build\win\hastyscribe.exe
