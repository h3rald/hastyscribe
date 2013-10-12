@echo off
nimrod --clibdir:vendor --clib:markdown c hastyscribe.nim
if exist hastyscribe.exe move hastyscribe.exe build\win\hastyscribe.exe
