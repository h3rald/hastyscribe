% HastyScribe User Guide
% Fabio Cevasco
% -

## Overview

[](class:hastyscribe) is a self-contained command-line {{mdlink -> [Markdown][df]}} compiler that can create single-file HTML documents. All documents created by {{hs -> HastyScribe}} use well-formed HTML and embed all stylesheets, fonts, and images that are necessary to display them in any (modern) browser.

In other words, all documents created by HastyScribe are constituted by only one [.HTML](class:ext) file, for easy distribution.

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
> You can learn about Markdown syntax in the [Syntax Reference](#Syntax.Reference) section of this document. Alternatively, you can also read the original [Markdown syntax page][md-syntax] on John Gruber's blog, Daring Fireball.

#### Discount Extensions

Standard markdown is great, but sometimes you wish it had a few more features, like tables or fenced codeblocks perhaps. The good news is that under the hood {{hs}} uses {{disclink}}, a markdown compiler library written in C that extends markdown with a few useful extensions, which allow you to:

* format blocks of texts to create [notes](#Notes) and [sidebar](#Sidebars)
* style text using CSS classes
* create definition lists and alphabetical lists

#### Text Snippets

Although not part of neither {{md}} nor Discount, {{hs}} allows you to create text [snippets](#Snippets) to reuse content. Useful when you have to use a sentence or a formatted block of text over and over in a document, or shorten long words (like the word {{hs}} in this document [](class:fa-smile-o)).

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

1. Download and install [Nimrod][nimrod].
2. Download/clone the HastyScribe [repository](https://github.com/h3rald/hastyscribe).
3. Put your **libmarkdown.a** file in the **vendor** directory.
4. Run **nixbuild** (if you are on OSX, Linux or other UNIX-like operating systems) or **winbuild.bat** (if you are on Windows) 

## Usage

{{hs}} is a command-line application that can compile one or more [.md](class:ext) or [.markdown](class:ext) files into one or more HTML file with the same name(s).

### Command Line Syntax

[hastyscribe](class:cmd) _filename-or-glob-expression_ **[** [--notoc](class:opt) **]**

Where:

  * _filename-or-glob-expression_ is a valid file or [glob](http://en.wikipedia.org/wiki/Glob_(programming)) expression ending in [.md](class:ext) or [.markdown](class:ext) that will be compiled into HTML.
  * [--notoc](class:opt) causes {{hs}} to output HTML documents _without_ automatically generated a Table of Contents at the start.

#### Examples (Windows)

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> hastyscribe.exe my\_markdown\_file.md

Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> hastyscribe.exe \*.md

#### Examples (Linux, OSX, etc.)

Executing {{hs}} to compile [my_markdown_file.md](class:file) within the current directory:

> %terminal%
> ./hastyscribe my\_markdown\_file.md
 
Executing {{hs}} to compile all [.md](class:ext) files within the current directory:

> %terminal%
> ./hastyscribe *.md

## Syntax Reference

### Document Headers

{{hs}} supports [Pandoc][pandoc]-style Document Headers, as implemented by the [Discount][discount] library. Basically, you can specify the title of the document, author and date as the first three lines of the document, prepending each with a [% ](class:kwd), like this 

~~~
% HastyScribe User Guide
% Fabio Cevasco
% -
~~~

Note that:

  * The order of the document headers is significant.
  * If you want to use the current date, enter [% -](class:kwd) in the third line.



### Inline Formatting 


> %responsive-table%
>  Source                                             | Output             
> ----------------------------------------------------|--------------------
> `**strong emphasis**` or `__strong emphasis__`      | __strong emphasis__
> `*emphasis*` or `_emphasis_`                        | *emphasis*
> `~~deleted text~~`                                  | ~~deleted text~~
> `<ins>inserted text<ins>`                           | <ins>inserted text</ins>
> ```code` ``                                         | `code`
> `[HTML](abbr:Hypertext Markup Language)`            | [HTML](abbr:Hypertext Markup Language)
> `<kbd>CTRL</kbd>+<kbd>C</kbd>`                      | <kbd>CTRL</kbd>+<kbd>C</kbd>
> `<mark>marked</mark>`                               | <mark>marked</mark>.
> `Sample output: <samp>This is a test.</samp>`       | Sample output: <samp>This is a test.</samp>
> `Set the variable <var>test</var> to 1.`            | Set the variable <var>test</var> to 1.
> `<q>This is a short quotation</q>`                  | <q>This is a short quotation</q>
> `<cite>Hamlet</cite>, by William Shakespeare.`      | <cite>Hamlet</cite>, by William Shakespeare.
> `A [.md](class:ext)` file                           | A [.md](class:ext) file
> `[my_markdown_file.md](class:file)` file            | [my_markdown_file.md](class:file) file
> `Execute [hastyscribe *.md](class:cmd)`             | Execute [hastyscribe *.md](class:cmd)           
> `The [--notoc](class:opt)` option                   | The [--notoc](class:opt) optiono




### SmartyPants Substitutions

Special characters can be easily entered using some special character sequences.

{{hs}} supports all the sequences supported by [Discount][discount]:

* <code>`` text‘’</code> &rarr; “text”.
* `"double-quoted text"` &rarr; “double-quoted text”
* `'single-quoted text'` &rarr; ‘single-quoted text’
* `don't` &rarr; don’t. as well as anything-else’t. (But foo'tbar is just foo'tbar.)
* it's` &rarr; it’s, as well as anything-else’s (except not foo'sbar and the like.)
* `(tm)` &rarr; ™
* `(r)` &rarr; ®
* `(c)` &rarr; ©
* `1/4th` &rarr; ¼th. Same goes for for 1/4 (¼), 1/2 (½), 3/4ths (¾ths), and 3/4 (¾).
* `...` or `. . .` &rarr; …
* `---` &rarr; —
* `--` &rarr; –
* `A^B` becomes A^B. Complex superscripts can be enclosed in brackets, so `A^(B+2)` &rarr; A^(B+2).


### Icons

{{hs}} bundles the [FontAwesome][fa] icon font. To prepend an icon to text you can use Discount's _class:_ pseudo-protocol, and specify a valid [fa-*](class:kwd) (non-alias) class.

Examples:

> %responsive%
> Source                                   | Output
> -----------------------------------------|------------
> `[a paper plane](class:fa-paper-plane)` | [ a paper plane](class:fa-paper-plane)
> `[Galactic Empire](class:fa-empire)`    | [ Galactic Empire](class:fa-empire)
> `[Rebel Alliance](class:fa-rebel)`      | [ Rebel Alliance](class:fa-rebel)

> %tip%
> Tip
> 
> See the [FontAwesome Icon Reference][fa-icons] for a complete list of all CSS classes to use for icons (aliases are not supported).

### Links

> %responsive%
> Source                                  | Output
> ----------------------------------------|------------
> `[H3RALD](https://h3rald.com/)`         | [H3RALD](https://h3rald.com/)
> `[H3RALD](https://h3rald.com/ "H3RALD")`| [H3RALD](https://h3rald.com/ "H3RALD")
> `<https://h3rald.com>`                  | <https://h3rald.com> 

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

{{input-text -> The following Markdown code:}}

~~~
![HastyScribe Logo](../assets/images/hastyscribe.png =316x93)
~~~

{{output-text -> Produces the following output:}}

![HastyScribe Logo](../assets/images/hastyscribe.png =316x93)

> %tip%
> Tip
> 
> You can use URL placeholders for images as well, exactly like for links.

### Lists

#### Unordered Lists

{{input-text}}

~~~
* An item
* Another item
  * A nested list
  * another item
* And another...
~~~

{{output-text}}

* An item
* Another item
  * A nested list
  * Another item
* And another...

#### Ordered Lists

{{input-text}}

~~~
1. First item
2. Second item
3. Third item
~~~

{{output-text}}

1. First item
2. Second item
3. Third item

> %tip%
> Tip
> 
> You don't have to write numbers in order -- any number followed by a dot will do. 

#### Alphabetical Lists

{{input-text}}

~~~
a. First item
b. Second item
c. Third item
~~~

{{output-text}}

a. First item
d. Second item
c. Third item

> %tip%
> Tip
> 
> You don't have to write letters in order -- any letter followed by a dot will do. 


#### Nested Lists

To create a list within a list, simply indent the whole nested list with four space. 


{{input-text}}

~~~
* This is a normal list
* Another item
    * A nested unordered list
    * Another item
* Back in the main list
    a. A nested alphabetical list
    b. Another item
~~~

{{output-text}}

* This is a normal list
* Another item
    * A nested unordered list
    * Another item
* Back in the main list
    a. A nested alphabetical list
    b. Another item

#### Definition Lists

In some cases you may want to write a list of terms and their corresponding definitions. You could use an ordinary unordered list, but semantically speaking the _proper_ type of list to use in this case is a definition list.

{{input-text}}

~~~
unordered list
: A list for unordered items. Also called _bulleted list_.
ordered list 
: A list for ordered items. Also called _numbered list_.
alphabetical list
: Technically speaking just an ordered list, but formatted with letters instead of numbers
definition list
: A list of terms and definitions.
~~~

{{output-text}}

unordered list
: A list for unordered items. Also called _bulleted list_.
ordered list 
: A list for ordered items. Also called _numbered list_.
alphabetical list
: Technically speaking just an ordered list, but formatted with letters instead of numbers
definition list
: A list of terms and definitions.

Alternatively, you can write the above definition list as follows:

~~~
=unordered list=
  A list for unordered items. Also called _bulleted list_.
=ordered list=
  A list for ordered items. Also called _numbered list_.
=alphabetical list=
  Technically speaking just an ordered list, but formatted with letters instead of numbers
=definition list=
  A list of terms and definitions.
~~~


### Block Styles

#### Headings

Headings can be specified simply by prepending [#](class:kwd)s, as follows: 

~~~
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
~~~

> %note%
> Note
> 
> If you use [Document Headers](#Document.Headers), A [H1](class:kwd) is used for the title of the {{hs}} document. Within the document, start using headings from [H2](class:kwd).

#### Tables

{{hs}} supports [PHP Markdown Extra][pme] table syntax using pipes and dashes.

{{input-text}}

> %responsive%
> ~~~
> Column Header 1 | Column Header 2 | Column Header 3 
> ----------------|-----------------|----------------
> Cell 1,1        | Cell 1,2        | Cell 1, 3
> Cell 2,1        | Cell 2,2        | Cell 2, 3
> Cell 3,1        | Cell 3,2        | Cell 3, 3
> ~~~

{{output-text}}

> %responsive%
> Column Header 1 | Column Header 2 | Column Header 3 
> ----------------|-----------------|----------------
> Cell 1,1        | Cell 1,2        | Cell 1, 3
> Cell 2,1        | Cell 2,2        | Cell 2, 3
> Cell 3,1        | Cell 3,2        | Cell 3, 3

> %note%
> Note
> 
> Multi-row cells are not supported. If you need more complex tables, use HTML code instead.

#### Block Quotes

Block quotes can be created simply by prepending a [>](class:kwd) to a line, and they can be nested by prepending additional [>](class:kwd)s.

{{input-text}}

~~~
> This is a block quote.
> > This is a nested quote. 
~~~

{{output-text}}

> This is a block quote.
> > This is a nested quote. 

### Notes

[Discount][discount] supports the definition of _class blocks_: [div](class:kwd)s with a class attribute. The syntax is very similar to the one used for [block quotes](#Block.Quotes), with the addition of the class name wrapped in [%](class:kwd)s on the first line. 

In {{hs}}, this syntax is used to produce notes, [tips](#Tips), [warmings](#Warnings) and [sidebars](#Sidebars).

{{input-text}}

~~~
> %note%
> Note
> 
> This is a note.
~~~

{{output-text}}

> %note%
> Note
> 
> This is a note.

### Tips

Tips are used for optional information that can help the user in some way. The syntax used for tips is similar to the one of [notes](#Notes).

{{input-text}}

~~~
> %tip%
> Tip
> 
> This is a tip.
~~~

{{output-text}}

> %tip%
> Tip
> 
> This is a tip.

### Warnings

Warnings are used for important information the user should not overlook. The syntax used for warnings is similar to the one of [notes](#Notes)

{{input-text}}

~~~
> %warning%
> Warning
> 
> This is a warning or an important note.
~~~

{{output-text}}

> %warning%
> Warning
> 
> This is a warning or an important note.

### Sidebars

Sidebars are used for digressions and asides. The syntax used for sidebars is similar to the one of [notes](#Notes).

{{input-text}}

~~~
> %sidebar%
> This is a _sidebar_
> 
> Although not always placed on the side of the page, _sidebars_ contain additional content and asides.
~~~

{{output-text}}

> %sidebar%
> This is a _sidebar_
> 
> Although not always placed on the side of the page, _sidebars_ contain additional content and asides.

#### Code Blocks


#### Badges


> %responsive%
> Class                | Badge                        | Class               | Badge 
> ---------------------|------------------------------|--------------------------------------------
> `todo`               | [](class:todo)               |`date`               | [](class:date)
> `fixme`              | [](class:fixme)              |`tag`                | [](class:tag) 
> `draftcomment`       | [](class:draftcomment)       |`attachment`         | [](class:attachment)
> `urgent`             | [](class:urgent)             |`bug`                | [](class:bug)
> `verify`             | [](class:verify)             |`geo`                | [](class:geo)
> `deadline`           | [](class:deadline)           |`eur`                | [](class:eur)
> `red-circle`         | [](class:red-circle)         |`gbp`                | [](class:gbp)
> `yellow-circle`      | [](class:yellow-circle)      |`usd`                | [](class:usd)
> `green-circle`       | [](class:green-circle)       |`rub`                | [](class:rub)
> `gray-circle`        | [](class:gray-circle)        |`jpy`                | [](class:jpy)
> `star`               | [](class:star)               |`btc`                | [](class:btc)
> `heart`              | [](class:heart)              |`try`                | [](class:try)
> `square`             | [](class:square)             |`krw`                | [](class:krw)
> `check`              | [](class:check)              |`inr`                | [](class:inr)
> `lock`               | [](class:lock)               |`danger`             | [](class:danger)
> `unlock`             | [](class:unlock)             |`question`           | [](class:question)

#### HastyScribe Logo

`[](class:hastyscribe)` &rarr; [](class:hastyscribe)

### Snippets

[\{\{test -> This is a test snippet\}\}](class:tt)

[\{\{test\}\}](class:tt)

## Credits

* Discount library
* FontAwesome v4.1.0
* Logo: Mr Bedfort font + Quill icon from Entypo icon set 
* Fonts: Source Sans Pro, Source Code Pro




[nimrod]: http://nimrod-code.org/
[df]: https://daringfireball.net/projects/markdown/
[discount]: http://www.pell.portland.or.us/~orc/Code/discount/
[pandoc]: http://johnmacfarlane.net/pandoc/
[md-syntax]: https://daringfireball.net/projects/markdown/syntax
[fa]:http://fortawesome.github.io/Font-Awesome/
[fa-icons]:http://fortawesome.github.io/Font-Awesome/icons/
[pme]:http://michelf.com/projects/php-markdown/extra/
