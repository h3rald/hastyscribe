# Usage

{{hs}} is a command-line application that can compile one or more Markdown files into one or more HTML files with the same name(s).

## Command Line Syntax

[hastyscribe](class:cmd) **[** [_&lt;options&gt;_](class:opt) **]** _filename-or-glob-expression_ ...

Where:

  * _filename-or-glob-expression_ is a valid markdown file or [glob](http://en.wikipedia.org/wiki/Glob_(programming\)) expression that will be compiled into HTML. Multiple files and/or globs are supported.
  * The following options are supported:
    * [\-\-output-file=&lt;file&gt;](class:opt) causes {{hs}} to write output to a local file (Use [\-\-output-file=-](class:opt) to output to standard output).
    * [\-\-output-dir=&lt;dir&gt;](class:opt) or [\-d=&lt;dir&gt;](class:opt) allow you to specify an output directory for the generated HTML files. When used, it will override the [\-\-output-file](class:opt) option. Please note that this option does not preserve the input directory structure (that, for example, can be observed while traversing glob patterns); all output files will be placed directly in the specified directory.
    * [\-\-field/&lt;field&gt;=&lt;value&gt;](class:opt) causes {{hs}} to set a custom field to a specific value.
    * [\-\-user-css=&lt;file&gt;](class:opt) causes {{hs}} to insert the contents of the specified local file as a CSS stylesheet. 
    * [\-\-user-js=&lt;file&gt;](class:opt) causes {{hs}} to insert the contents of the specified local file as a Javascript script. 
    * [\-\-watermark=&lt;file&gt;](class:opt) causes {{hs}} to embed and display an image as a watermark throughout the document. 
    * [\-\-notoc](class:opt) causes {{hs}} to output HTML documents _without_ automatically generating a Table of Contents at the start.
    * [\-\-noembed](class:opt) causes styles and images not to be embedded.
    * [\-\-fragment](class:opt) causes {{hs}} to output just an HTML fragment instead of a full document, without embedding any image, font or stylesheet.
    * [\-\-iso](class:opt) enables {{hs}} to use the ISO 8601 date format (e.g., 2000-12-31) in the footer of the generated HTML documents.
    * [\-\-no-clobber](class:opt) or [\-n](class:opt) prevents {{hs}} from overwriting existing files. If a file with the same name already exists, {{hs}} will issue a warning and will not overwrite it.
    * [\-\-help](class:opt) causes {{hs}} to display the usage information and quit.

## Linux and macOS Examples 

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> ./hastyscribe my\_markdown\_file.md
 
Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> ./hastyscribe \*.md

Executing {{hs}} to compile all [.md](class:ext) files within the current and [in](clas:file) directories and save all the files to directory [out](class:file), preventing any overwrites:

> %terminal%
> ./hastyscribe --no-clobber -d=out \*.md in/\*.md

## Windows Examples

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> hastyscribe.exe my\_markdown\_file.md

Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> hastyscribe.exe \*.md

Executing {{hs}} to compile all [.md](class:ext) files within the current and [in](clas:file) directories and save all the files to directory [out](class:file), preventing any overwrites:

> %terminal%
> hastyscribe.exe --no-clobber -d=out \*.md in\\\*.md

> %tip%
> Tip
> 
> You can also drag a Markdown file directly on [hastyscribe.exe](class:kwd) to compile it to HTML.
