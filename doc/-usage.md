# Usage

{{hs}} is a command-line application that can compile one or more Markdown files into one or more HTML files with the same name(s).

## Command Line Syntax

[hastyscribe](class:cmd) _filename-or-glob-expression_ **[** [_<options\>_](class:opt) **]**

Where:

  * _filename-or-glob-expression_ is a valid file or [glob](http://en.wikipedia.org/wiki/Glob_(programming)) expression that will be compiled into HTML.
  * The following options are supported:
    * [\-\-field/&lt;field&gt;=&lt;value&gt;](class:opt) causes {{hs}} to set a custom field to a specific value.
    * [\-\-notoc](class:opt) causes {{hs}} to output HTML documents _without_ automatically generating a Table of Contents at the start.
    * [\-\-user-css=&lt;file&gt;](class:opt) causes {{hs}} to insert the contents of the specified local file as a CSS stylesheet. 
    * [\-\-user-js=&lt;file&gt;](class:opt) causes {{hs}} to insert the contents of the specified local file as a Javascript script. 
    * [\-\-output-file=&lt;file&gt;](class:opt) causes {{hs}} to write output to a local file (Use [\-\-output-file=-](class:opt) to output to standard output).
    * [\-\-watermark=&lt;file&gt;](class:opt) causes {{hs}} to embed and display an image as a watermark throughout the document. 
    * [\-\-fragment](class:opt) causes {{hs}} to output just an HTML fragment instead of a full document, without embedding any image, font or stylesheet.

## Linux/OSX Examples 

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> ./hastyscribe my\_markdown\_file.md
 
Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> ./hastyscribe \*.md

## Windows Examples

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> hastyscribe.exe my\_markdown\_file.md

Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> hastyscribe.exe \*.md

> %tip%
> Tip
> 
> You can also drag a Markdown file directly on [hastyscribe.exe](class:kwd) to compile it to HTML.
