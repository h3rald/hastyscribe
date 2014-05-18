% HastyScribe User Guide
% Fabio Cevasco
% -

## Overview

{{hs -> HastyScribe}} is a single-file command-line application that can create self-contained HTML documents from well-formatted {{mdlink -> [markdown][df]}} files. All documents created by markdown use well-formed HTML and embed all assets that are necessary to display them in any (modern) browser, i.e.:

  * CSS stylesheets
  * Javascript code
  * Fonts
  * Images

In other words, all documents created by HastyScribe are constituted by only one .HTML file only, for easy redistribution.

### Rationale

There are plenty of programs and services that can convert {{mdlink}} into HTML but they are typically either too simple --they convert {{md -> markdown}} code into an HTML fragment-- or too complex --they produce a well-formed document, but they require too much configuration, install additional software dependencies.

Sometimes you just want to write your document in markdown, and get a full HTML file out, ready to be distributed, ideally with no dependencies (external stylesheets or images) --that's where {{hs}} comes in.

{{hs}}:

* lets you focus on content and keeps things simple, while giving you all the power of {{disclink -> [Discount][discount]}}-enriched {{md}} (plus some more goodies).
* takes care of styling your documents properly, making sure they look good on your desktop and even on small screens, so that they are ready to be distributed. 
* is a single, small executable file, with no dependencies.

### Key Features

#### Standard Markdown

{{hs}} supports standard {{md}} for formatting text. Markdown is a lightweight markup language created by John Gruber, and used on many web sites and programs to enable users to write HTML code _without actually writing HTML tags_. 

> %tip%
> Tip
> 
> You can learn about Markdown [syntax][md-syntax] on John Gruber's blog, Daring Fireball, but it is also covered in the [Syntax Reference](#Syntax.Reference) section.

#### Discount Extensions

Standard markdown is great, but sometimes you wish it had a few more features, like tables or fenced codeblocks perhaps. The good news is that under the hood {{hs}} uses {{disclink}}, a markdown compiler library written in C that extends markdown with a few useful extensions, which allows you to:

* format blocks of texts to create [notes](#Notes) and [sidebar](#Sidebars)
* style text using CSS classes
* create definition lists and alphabetical lists

#### Text Snippets

Although not part of {{md}} or Discount, {{hs}} allows you to create text [snippets](#Snippets) to reuse content. Useful when you have to use a sentence or a formatted block of text over and over in a document, or shorten long words (like the word {{hs}} in this document [](class:fa-smile-o)).

#### Syntax Highlighting

No need to worry about formatting a block of code or even specifying the programming language you used. Thanks to {{highlightjs -> [highlight.js](http://highlightjs.org/)}}, every code block is properly highlighted automatically. Like this Javascript snippet:

~~~
$(document).ready(function() {
  $("a").click(function( event ) {
    alert("Thanks for visiting!");
  });
});
~~~

#### Image (and font) Embedding

{{hs}} only produces single HTML files. With _no dependencies_:

* By default, the FontAwesome, Source Sans Pro, and Source Code Pro font are automatically embedded.
* All referenced local images are automatically embedded using the {{datauri -> [data URI scheme](http://en.wikipedia.org/wiki/Data_URI_scheme)}}.

#### FontAwesome Icons

[](class:fa-question-circle)[](class:fa-question-circle)

[](class:fa-star)[](class:fa-lightbulb-o)[](class:fa-exclamation-circle) [](class:fa-thumbs-up) [](class:fa-smile-o)[](class:fa-smile-o)

#### Notes, tips, warnings, sidebars and badges

> %sidebar%
> About notes etc.
> 
> HastyScribe has built-in [tips](#Tips), [notes](#Notes), [warnings](#Warnings), [sidebars](#Sidebars), like this one.

[...and this is a comment badge.](class:draftcomment)

#### Responsive Design

All HTML documents created by {{hs}} are responsive and can be viewed perfectly on small devices.

## Getting Started

### Downloading Pre-built Binaries

[Provide actual links to the release downloads](class:todo)

### Building from Source

You can also build HastyScribe from source, if there is no pre-built binary for your platform.

First of all you need a **libmarkdown.a** static library. You can either grab one precompiled (for Windows x64 or OSX x64) from the [vendor](https://github.com/h3rald/hastyscribe/blob/master/vendor) folder of the {{hs}} repository or build your own. 

If you choose to build your own:

1. Download/clone [Discount](https://github.com/Orc/discount) source code
2. In the directory containing Discount source code, run the following commands:

   > %terminal%
   > ./configure.sh --with-tabstops=2 --with-dl=both --with-id-anchor --with-github-tags --with-fenced-code --enable-all-features
   > 
   > make

   > %note%
   > Note
   > 
   > If you are on Windows, you can compile it using [MinGW](http://www.mingw.org/).

Once you have a **libmarkdown.a** static library for your platform:

1. Download and install [Nimrod][nimrod]. On OSX you can also <tt>brew install nimrod</tt> if you have [HomeBrew](http://brew.sh/) installed.
2. Download/clone the HastyScribe [repository](https://github.com/h3rald/hastyscribe).
3. Put your **libmarkdown.a** file in the **vendor** directory.
4. Run **osxbuild** (if you are on OSX) or **winbuild.bat** (if you are on windows) or the following:

   > %terminal%
   > nimrod --clibdir:vendor --clib:markdown c hastyscribe.nim

[nimrod]: http://nimrod-code.org/

## Usage

{{hs}} is a command-line application that can compile one or more <tt>.md</tt> or <tt>.markdown</tt> files into one or more HTML file with the same name(s).

### Command Line Syntax

**hastyscribe** _filename-or-glob-expression_ **[** <tt>--notoc</tt> **]**

Where:

  * _filename-or-glob-expression_ is a valid file or [glob](http://en.wikipedia.org/wiki/Glob_(programming)) expression ending in <tt>.md</tt> or <tt>.markdown</tt> that will be compiled into HTML.
  * <tt>--notoc</tt> causes {{hs}} to output HTML documents _without_ automatically generated a Table of Contents at the start.

#### Examples

> %windows-sidebar%
> Windows
> 
> Executing {{hs}} to compile <tt>my_markdown_file.md</tt> within the current directory:
>> %terminal%
>> hastyscribe.exe my_markdown_file.md
> 
> Executing {{hs}} to compile all <tt>.md</tt> files within the current directory:
>> %terminal%
>> hastyscribe.exe *.md

> %apple-linux-sidebar%
> OS X/Linux/etc.
> 
> Executing {{hs}} to compile <tt>my_markdown_file.md</tt> within the current directory:
>> %terminal%
>> ./hastyscribe my_markdown_file.md
> 
> Executing {{hs}} to compile all <tt>.md</tt> files within the current directory:
>> %terminal%
>> ./hastyscribe *.md

## Syntax Reference

### Document Headers

{{hs}} supports [Pandoc][pandoc]-style Document Headers, as implemented by the [Discount][discount] library. Basically, you can specify the title of the document, author and date as the first three lines of the document, prepending each with a <tt>% </tt>, like this 

~~~
% HastyScribe User Guide
% Fabio Cevasco
% -
~~~

Note that:

  * The order of the document headers is significant.
  * If you want to use the current date, enter <tt>% -</tt> in the third line.



### Text Decorations

 Source                                             | Output             
----------------------------------------------------|--------------------
`**strong emphasis**` or `__strong emphasis__`      | __strong emphasis__
`*emphasis*` or `_emphasis_`                        | *emphasis*
`~~deleted text~~`                                  | ~~deleted text~~
`<ins>inserted text<ins>`                           | <ins>inserted text</ins>
```code` ``                                         | `code`
`[HTML](abbr:Hypertext Markup Language)`            | [HTML](abbr:Hypertext Markup Language)
`<kbd>CTRL</kbd>+<kbd>C</kbd>`                      | <kbd>CTRL</kbd>+<kbd>C</kbd>
`<mark>marked</mark>`                               | <mark>marked</mark>.
`Sample output: <samp>This is a test.</samp>`       | Sample output: <samp>This is a test.</samp>
`Set the variable <var>test</var> to 1.`            | Set the variable <var>test</var> to 1.
`<q>This is a short quotation</q>`                  | <q>This is a short quotation</q>
`<cite>Hamlet</cite>, by William Shakespeare.`      | <cite>Hamlet</cite>, by William Shakespeare.
`<tt>Teletype text</tt>`                            | <tt>Teletype text</tt>


### SmartyPants Substitutions

(TM), (R), 1/4, 1/2, ---, --, A^(B+2), ... 

### Icons

### Links

Source                                  | Output
----------------------------------------|------------
`[H3RALD](https://h3rald.com/)`         | [H3RALD](https://h3rald.com/)
`[H3RALD](https://h3rald.com/ "H3RALD")`| [H3RALD](https://h3rald.com/ "H3RALD")
`<https://h3rald.com>`                  | <https://h3rald.com> 

Additionally, you can define placeholders for URLs and link titles, like this:

`h3rald]: https://h3rald.com/ "Fabio Cevasco's Web Site"`

And use them in hyperlinks (note the usage of square brackets instead of round brackets):

`[H3RALD][h3rald]`

> %sidebar%
> Link Icons
> 
> {{hs}} automatically adds an envelope icon to email links, an arrow icon to links to external web sites, and logo icons to links to well-known web sites:
> 
> * [h3rald@h3rad.com](mailto://h3rald@h3rald.com)
> * [@h3rald](https://twitter.com/h3rald)
> * [fabiocevasco](http://it.linkedin.com/in/fabiocevasco)

### Images

### Lists

#### Unordered Lists

* An item
* Another item
* And another...


#### Ordered Lists

1. First item
2. Second item
3. Third item


#### Alphabetical Lists

a. First item
b. Second item
c. Third item

#### Definition Lists

test
: Test definition
test 2 
: Another test definition
test 3
: Another test definition


### Block Styles

#### Headings

#### Tables

| Test | Test... |
|------|---------|
|sdgsag|fdgsdh d |
| fds  | fdhdfsh |


#### Block Quotes

> This is a block quote.
> > This is a nested quote. 

#### Code Blocks

```
$(document).ready(function(){
  $("p").click(function(){
    $(this).hide();
  });
});
```

### Notes

> %note%
> Note
> 
> This is a note.

### Tips

> %tip%
> Tip
> 
> This is a tip.


### Warnings

> %warning%
> Warning
> 
> This is an important note.

### Sidebars

> %sidebar%
> This is a _sidebar_
> 
> Although not always placed on the side of the page, _sidebars_ contain additional content and asides.


#### Addresses

<address>
Written by <a href="mailto:webmaster@example.com">Jon Doe</a>.<br> 
Visit us at:<br>
Example.com<br>
Box 564, Disneyland<br>
USA
</address>


#### Badges

* [Do Something](class:todo)
* [Do something](class:fixme) 
* [This is a comment](class:draftcomment)
* [Red circle](class:red-circle) [Yellow circle](class:yellow-circle) [Green circle](class:green-circle) [Gray circle](class:gray-circle)
* [](class:star) [](class:heart) 
* [no](class:square) [yes!](class:check)
* [locked](class:lock) [unlocked](class:unlock)
* [bug](class:bug)
* [tomorrow](class:date)
* [tag](class:tag)
* [test.txt](class:attachment)
* [100](class:eur) [100](class:gbp) [100](class:usd) [100](class:rub) [100](class:jpy) [100](class:btc) [100](class:try) [100](class:krw) [100](class:inr)


### Snippets

## Credits

* FontAwesome v4.1.0
* highlighting.hs v0.8
* nanodom v0.0.3
* Quill icon by Joan Ang from The Noun Project


---

[df]: https://daringfireball.net/projects/markdown/
[discount]: http://www.pell.portland.or.us/~orc/Code/discount/
[pandoc]: http://johnmacfarlane.net/pandoc/
[md-syntax]: https://daringfireball.net/projects/markdown/syntax
