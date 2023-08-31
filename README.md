[![Nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/hastyscribe)

![release](https://img.shields.io/github/release/h3rald/hastyscribe.svg)
![license](https://img.shields.io/github/license/h3rald/hastyscribe.svg)

# HastyScribe

_HastyScribe_ is a simple command-line program able to convert [markdown](http://daringfireball.net/projects/markdown) files into HTML files.

## Usage

**hastyscribe** _filename-or-glob-expression_ **[** _&lt;options&gt;_ **]**

Where:

- _filename-or-glob-expression_ is a valid file or [glob](<http://en.wikipedia.org/wiki/Glob_(programming)>) expression that will be compiled into HTML.
- The following options are supported:
  - **\-\-field/&lt;field&gt;=&lt;value&gt;** causes HastyScribe to set a custom field to a specific value.
  - **\-\-notoc** causes HastyScribe to output HTML documents _without_ automatically generating a Table of Contents at the start.
  - **\-\-user-css=&lt;file&gt;** causes HastyScribe to insert the contents of the specified local file as a CSS stylesheet.
  - **\-\-user-js=&lt;file&gt;** causes HastyScribe to insert the contents of the specified local file as a Javascript script.
  - **\-\-output-file=&lt;file&gt;** causes HastyScribe to write output to a local file (Use [\-\-output-file=-](class:opt) to output to standard output).
  - **\-\-watermark=&lt;file&gt;** causes HastyScribe to embed and display an image as a watermark throughout the document.
  - **\-\-fragment** causes HastyScribe to output just an HTML fragment instead of a full document, without embedding any image, font or stylesheet.
  - **\-\-noembed** causes styles and images not to be embedded.
  - **\-\-help** causes HastyScribe to display the usage information and quit.

&rarr; For more information, see the [HastyScribe User Guide](https://h3rald.com/hastyscribe/HastyScribe_UserGuide.htm)
