[![Release](https://img.shields.io/github/release/h3rald/hastyscribe.svg)](https://github.com/h3rald/hastyscribe)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/h3rald/hastyscribe/master/LICENSE)
[![Build Status](https://img.shields.io/travis/h3rald/hastyscribe.svg)](https://travis-ci.org/h3rald/hastyscribe)

# HastyScribe

_HastyScribe_ is a simple command-line program able to convert [markdown](http://daringfireball.net/projects/markdown) files into HTML files.

## Usage

**hastyscribe** _filename-or-glob-expression_ **[** _\<options\>_ **]**

Where:

  * _filename-or-glob-expression_ is a valid file or [glob](http://en.wikipedia.org/wiki/Glob_(programming)) expression that will be compiled into HTML.
  * The following options are supported:
    * **\-\-field/&lt;field&gt;=&lt;value&gt;** causes HastyScribe to set a custom field to a specific value.
    * **\-\-notoc** causes HastyScribe to output HTML documents _without_ automatically generating a Table of Contents at the start.
    * **\-\-user-css=&lt;file&gt;** causes HastyScribe to insert the contents of the specified local file as a CSS stylesheet. 
    * **\-\-user-js=&lt;file&gt;** causes HastyScribe to insert the contents of the specified local file as a Javascript script. 
    * **\-\-output-file=&lt;file&gt;** causes HastyScribe to write output to a local file (Use [\-\-output-file=-](class:opt) to output to standard output).
    * **\-\-watermark=&lt;file&gt;** causes HastyScribe to embed and display an image as a watermark throughout the document. 
    * **\-\-fragment** causes HastyScribe to output just an HTML fragment instead of a full document, without embedding any image, font or stylesheet.
    * **\-\-dump=all|styles|fonts** causes HastyScribe to dump all resources/stylesheets/fonts to the current directory.

## FAQs

### Why is _HastyScribe_ different from other markdown converters?

Because:

* It is a cross-platform, self-contained executable file.
* It can generate standalon HTML files.
* It comes with its own stylesheet, which is automatically embedded into every HTML document, along with all the needed web fonts.
* It is built on top of [Discount][discount], which means that besides standard markdown you also get:
  * strikethrough
  * automatic Table of Contents generation
  * [SmartyPants](http://daringfireball.net/projects/smartypants/) substitutions
  * paragraph centering
  * image sizes
  * definition lists
  * alphabetic lists
  * pseudo-protocols to generate `span` tags with arbitrary CSS classes, `abbr` tags, and anchors
  * class blocks
  * tables
  * fenced code blocks
  * [Pandoc](http://johnmacfarlane.net/pandoc/)-style document headers
* It automatically embeds any referenced image as data URI.
* It has supports for text snippets, custom fields, and substitution macros.

### What can I use it for?

_HastyScribe_ is best suited to produce self-contained documents such as essays, meeting notes, project status documents, and articles.

### What language is _HastyScribe_ implemented in?

HastyScribe is implemented in [Nim][nim], a very expressive language that compiles to C and is able to generate small, standalone and self-contained executable files.

### How do I build _HastyScribe_ from source?

1. Download and install [Nim][nim].
2. Download and build [Nifty][nifty], and put it somewhere in your $PATH.
3. Clone the HastyScribe [repository](https://github.com/h3rald/hastyscribe).
4. Navigate to the HastyScribe repository local folder.
5. Run **nifty install** to download HastyScribe's dependencies.
6. Run **nifty build discount** to build the Discount markdown library.
7. Run **nim c -d:release -d:discount hastyscribe.nim**

[nim]: http://nim-lang.org/
[nifty]: https://github.com/h3rald/nifty
[discount]: http://www.pell.portland.or.us/~orc/Code/discount/
