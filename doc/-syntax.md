# Syntax Reference

## Document Headers

{{hs}} supports [Pandoc][pandoc]-style Document Headers, as implemented by the [Discount][discount] library. Basically, you can specify the title of the document, author and date as the first three lines of the document, prepending each with a [%](class:kwd), like this 

~~~
% HastyScribe User Guide
% Fabio Cevasco
% -
~~~

> %warning%
> Important
> 
>  * The order of the document headers is significant.
>  * If you want to use the current date, enter [% -](class:kwd) in the third line.

## Transclusion

When writing a long document, it is often useful to split it into many different files, to manage its contents better. {{hs}} provides basic content transclusion support through the following syntax:

<code>\{@ my-file.md || 1 @\}</code>

When a file is processed, the line above will cause the contents of file [my-file.md](class:file) to be included in the current file, as if they were part of it. Additionally, when using content transclusion syntax, it is mandatory to specify a number between 0 and 5 to indicate the _offset_ of the headings present in the transcluded file. In this example, the heading numbers of all headings present in [my-file.md](class:file) will be increased by 1, so any [h2](class:kwd) will become [h3](class:kwd), any [h3](class:kwd) will become [h4](class:kwd), and so on.

> %warning%
> Limitations
> 
> * It is recommended to place all transcluded files in the same folder as the transcluding file. If a transcluded file includes any image, its relative path will be interpreted as if it was relative to the transcluding file.
> * Heading offset will only work if headings are created using [#](class:kwd)s. Underline syntax for [h1](class:kwd) and [h2](class:kwd) is not supported.

## Snippets

If you want to reuse a few words or even entire blocks of texts, you can use {{hs}}'s snippets. 

A snippet definition is constituted by an identifier, followed by an arrow ([->](class:kwd)), followed by some text -- all wrapped in double curly brackets. 

The following definition creates a snippet called [test](class:kwd) which is transformed into the text "This is a test snippet.". 

<code>\{\{test -> This is a test snippet.\}\}</code>

Once a snippet is defined _anywhere_ in the document, you can use its identifier wrapped in double curly brackets (<code>\{\{test}\}\}</code> in the previous example) anywhere in the document to reuse the specified text.

> %sidebar%
> Alternative Snippet Definition Syntax
> 
> When a document is compiled, both snippets _and snippet defininotions_ are evaluated to their body text. To avoid snippet definitions being evaluated, you can use a double arrow ([=>](class:kwd)) in the definition:
> 
> <code>\{\{test => This snippet definition will not be evaluated to its body text.\}\}</code>

## Fields

Besides user-defined snippets, {{hs}} also support fields, which can be used to insert current time and date information in a variety of formats:

> %responsive%
> Source                                      | Output
> --------------------------------------------|----------------------
> <code>\{\{$timestamp\}\}</code>             | {{$timestamp}}
> <code>\{\{$date\}\}</code>                  | {{$date}}
> <code>\{\{$full-date\}\}</code>             | {{$full-date}}
> <code>\{\{$long-date\}\}</code>             | {{$long-date}}
> <code>\{\{$medium-date\}\}</code>           | {{$medium-date}}
> <code>\{\{$short-date\}\}</code>            | {{$short-date}}
> <code>\{\{$short-time\}\}</code>            | {{$short-time}}
> <code>\{\{$short-time-24\}\}</code>         | {{$short-time-24}}
> <code>\{\{$time\}\}</code>                  | {{$time}}
> <code>\{\{$time-24\}\}</code>               | {{$time-24}}
> <code>\{\{$day\}\}</code>                   | {{$day}}
> <code>\{\{$short-day\}\}</code>             | {{$short-day}}
> <code>\{\{$month\}\}</code>                 | {{$month}}
> <code>\{\{$short-month\}\}</code>           | {{$short-month}}
> <code>\{\{$year\}\}</code>                  | {{$year}}
> <code>\{\{$short-year\}\}</code>            | {{$short-year}}
> <code>\{\{$weekday\}\}</code>               | {{$weekday}}
> <code>\{\{$weekday-abbr\}\}</code>          | {{$weekday-abbr}}
> <code>\{\{$month-name\}\}</code>            | {{$month-name}}
> <code>\{\{$month-name-abbr\}\}</code>       | {{$month-name-abbr}}
> <code>\{\{$timezone-offset\}\}</code>       | {{$timezone-offset}}

Additionally, you can define your own custom fields via command-line parameters, using the [\-\-field/](class:arg) dynamic parameter, like this:

> %terminal%
> hastyscribe my-document.md \-\-field/product:HastyScribe \-\-field/version:1.2.0

In this case it will be possible to access the [product](class:kwd) and [product](class:kwd) fields within [my-document.md](class:file) using <code>\{\{$product\}\}</code> and <code>\{\{$version\}\}</code>.

## Macros

If snippets are not enough, and you want to reuse chunks of _similar_ content, you can define substitution macros using the following syntax:

<code>\{#greet => Hello, $1! Are you $2?#\}</code>

This defines a macro called [greet](class:kwd) that takes two parameters which will be substituted instead of [$1](class:kwd) and [$2](class:kwd). To use the macro, use the following syntax:

<code>\{#greet||Fabio||ready#\}</code>

> %note%
> Note
> 
> * Like snippets, macros can be multiline.
> * Spaces and newline character are preseved ad the start and end of parameters.
> * You can use snippets and fields within macros (but you cannot nest macros inside other macros).
> * You can define macros using either [->](class:kwd) or [=>](class:kwd), although [=>](class:kwd) is preferred.

{@ -syntax-inline.md || 1 @}

{@ -syntax-block.md || 1 @}
