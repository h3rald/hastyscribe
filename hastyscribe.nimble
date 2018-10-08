import
  ospaths

template thisModuleFile: string = instantiationInfo(fullPaths = true).filename

when fileExists(thisModuleFile.parentDir / "src/hastyscribepkg/config.nim"):
  # In the git repository the Nimble sources are in a ``src`` directory.
  import src/hastyscribepkg/config
else:
  # When the package is installed, the ``src`` directory disappears.
  import hastyscribepkg/config

# Package

version       = pkgVersion
author        = pkgAuthor
description   = pkgDescription
license       = "MIT"
bin           = @["hastyscribe"]
srcDir        = "src"
installFiles  = @["nifty.json"]

requires "nim >= 0.19.0"

before install:
  exec "nifty install"

# Tasks

const
  compile = "nim c -d:release"
  linux_x86 = "--cpu:i386 --os:linux"
  linux_x64 = "--cpu:amd64 --os:linux"
  linux_arm = "--cpu:arm --os:linux"
  windows_x64 = "--cpu:amd64 --os:windows"
  macosx_x64 = ""
  hs = "src/hastyscribe"
  hs_file = "src/hastyscribe.nim"
  zip = "zip -X"

proc shell(command, args: string, dest = "") =
  exec command & " " & args & " " & dest

proc filename_for(os: string, arch: string): string =
  return "hastyscribe" & "_v" & version & "_" & os & "_" & arch & ".zip"

task windows_x64_build, "Build HastyScribe for Windows (x64)":
  shell compile, windows_x64, hs_file

task linux_x86_build, "Build HastyScribe for Linux (x86)":
  shell compile, linux_x86,  hs_file
  
task linux_x64_build, "Build HastyScribe for Linux (x64)":
  shell compile, linux_x64,  hs_file
  
task linux_arm_build, "Build HastyScribe for Linux (ARM)":
  shell compile, linux_arm,  hs_file
  
task macosx_x64_build, "Build HastyScribe for Mac OS X (x64)":
  shell compile, macosx_x64, hs_file

task release, "Release HastyScribe":
  echo "\n\n\n WINDOWS - x64:\n\n"
  windows_x64_buildTask()
  shell zip, filename_for("windows", "x64"), hs & ".exe"
  shell "rm", hs & ".exe"
  echo "\n\n\n LINUX - x64:\n\n"
  linux_x64_buildTask()
  shell zip, filename_for("linux", "x64"), hs 
  shell "rm", hs 
  echo "\n\n\n LINUX - x86:\n\n"
  linux_x86_buildTask()
  shell zip, filename_for("linux", "x86"), hs 
  shell "rm", hs 
  echo "\n\n\n LINUX - ARM:\n\n"
  linux_arm_buildTask()
  shell zip, filename_for("linux", "arm"), hs 
  shell "rm", hs 
  echo "\n\n\n MAC OS X - x64:\n\n"
  macosx_x64_buildTask()
  shell zip, filename_for("macosx", "x64"), hs 
  shell "rm", hs 
  echo "\n\n\n ALL DONE!"
