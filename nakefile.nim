import nake

const
  compile = "nimrod c"
  linux_x86 = "--cpu:i386 --os:linux"
  windows_x86 = "--cpu:i386 --os:windows"
  parallel = "--parallelBuild:1"
  hs = "hastyscribe.nim"

task "windows-build", "Build HastyScribe for Windows (x86)":
  direshell compile, windows_x86, hs

task "linux-build", "Build HastyScribe for Linux (x86)":
  direshell compile, linux_x86, hs 
  
task "macosx-build", "Build HastyScribe for Mac OS X (x86)":
  direshell compile, hs
