# Getting Started

## Downloading Pre-built Binaries

{# release -> [HastyScribe for $1]({{release}}{{$version}}/hastyscribe_v{{$version}}_$2.zip)#}

The easiest way to get {{hs}} is by downloading one of the prebuilt binaries from the [Github Release Page][release]:

  * {#release||Mac OS X (x64)||macosx_x64#}
  * {#release||Windows (x64)||windows_x64#}
  * {#release||Linux (x64)||linux_x64#}

## Installing using Nimble

If you already have [Nim][nim] installed on your computer, you can simply run

[nimble install hastyscribe](class:cmd)

## Building from Source

You can also build HastyScribe from source, if there is no pre-built binary for your platform.

To do so, you can:

1. Download and install [Nim][nim].
2. Download and build [Nifty][nifty], and put the nifty executable somewhere in your $PATH.
3. Clone the HastyScribe [repository]({{repo -> https://github.com/h3rald/hastyscribe}}).
4. Navigate to the HastyScribe repository local folder.
5. Run **nifty install** to download HastyScribe's dependencies.
6. Run **nifty build discount** to build the Discount markdown library.
7. Run **nim c -d:release -d:discount hastyscribe.nim**
