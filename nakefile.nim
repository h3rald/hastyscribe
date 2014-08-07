import nake
from version import v

const
  compile = "nimrod c -d:release"
  linux_x86 = "--cpu:i386 --os:linux"
  windows_x86 = "--cpu:i386 --os:windows"
  parallel = "--parallelBuild:1"
  hs = "hastyscribe"
  hs_file = "hastyscribe.nim"
  zip = "zip -X"

proc filename_for(os: string, arch: string): string =
  return "hastyscribe" & "_v" & v & "_" & os & "_" & arch & ".zip"

task "windows-build", "Build HastyScribe for Windows (x86)":
  direshell compile, "--cpu:i386 --os:windows", hs_file

task "linux-build", "Build HastyScribe for Linux (x86)":
  direshell compile, "--cpu:i386 --os:linux", hs_file
  
task "macosx-build", "Build HastyScribe for Mac OS X (x86)":
  direshell compile, hs_file

task "release", "Release HastyScribe":
  echo "\n\n\n WINDOWS:\n\n"
  runTask "windows-build"
  direshell zip, filename_for("windows", "x86"), hs & ".exe"
  direshell "rm", hs & ".exe"
  echo "\n\n\n LINUX:\n\n"
  runTask "linux-build"
  direshell zip, filename_for("linux", "x86"), hs 
  direshell "rm", hs 
  echo "\n\n\n MAC OS X:\n\n"
  runTask "macosx-build"
  direshell zip, filename_for("macosx", "x86"), hs 
  direshell "rm", hs 
  echo "\n\n\n ALL DONE!"
