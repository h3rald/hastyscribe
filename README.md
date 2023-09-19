[![Nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/hastyscribe)

![release](https://img.shields.io/github/release/h3rald/hastyscribe.svg)
![license](https://img.shields.io/github/license/h3rald/hastyscribe.svg)

# HastyScribe

_HastyScribe_ is a simple command-line program able to convert [markdown](http://daringfireball.net/projects/markdown) files into HTML files.

## Usage

**hastyscribe** **[** options **]** _filename-or-glob-expression_ ...

Where:

- _filename-or-glob-expression_ is a valid markdown file or [glob](<http://en.wikipedia.org/wiki/Glob_(programming)>) expression that will be compiled into HTML. Multiple files and/or globs are supported.
- The following options are supported:
  - **--output-file=<file>** causes HastyScribe to write output to a local file (Use `--output-file=-` to output to standard output).
  - **--output-dir=<dir>** or **-d=<dir>** allow you to specify an output directory for the generated HTML files. When used, it will override the `--output-file` option. Please note that this option does not preserve the input directory structure (that, for example, can be observed while traversing glob patterns); all output files will be placed directly in the specified directory.
  - **--field/<field>=<value>** causes HastyScribe to define custom field and set it to a specific value.
  - **--user-css=<file>** causes HastyScribe to insert the contents of the specified local file as a CSS stylesheet.
  - **--user-js=<file>** causes HastyScribe to insert the contents of the specified local file as a Javascript script.
  - **--watermark=<file>** causes HastyScribe to embed and display an image as a watermark throughout the document.
  - **--notoc** causes HastyScribe to output HTML documents _without_ automatically generating a Table of Contents at the start.
  - **--noembed** causes styles and images not to be embedded.
  - **--fragment** causes HastyScribe to output just an HTML fragment instead of a full document, without embedding any image, font or stylesheet.
  - **--iso** enables HastyScribe to use the ISO 8601 date format (e.g., 2000-12-31) in the footer of the generated HTML documents.
  - **--minify-css** uses an unsophisticated minifier on the built-in stylesheet before embedding it into HTML. Ignored when combined with `--noembed`.
  - **--no-clobber** or **-n** prevents HastyScribe from overwriting existing files. If a file with the same name already exists, HastyScribe will issue a warning and will not overwrite it.
  - **--help** causes HastyScribe to display the usage information and quit.

&rarr; For more information, see the [HastyScribe User Guide](https://h3rald.com/hastyscribe/HastyScribe_UserGuide.htm)
