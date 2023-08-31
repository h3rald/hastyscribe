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

To build on a different operating system and architecture from the ones for which a pre-built binary is provided, you also need to get or build the `markdown` static library (see [Orc/discount](https://github.com/Orc/discount) for more information and sources).

Then:

1. Download and install [Nim][nim].
3. Clone the HastyScribe [repository]({{repo -> https://github.com/h3rald/hastyscribe}}).
4. Run the following command:

   `nimble build -d:release --passL:"-static -L<dir> -lmarkdown"`

Where `<dir>` is a directory containing the `libmarkdown.a` static library.
