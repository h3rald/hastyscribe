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


## Snippets

If you want to reuse a few words or even entire blocks of texts, you can use {{hs}}'s snippets. 

A snippet definition is constituted by an identifier, followed by an arrow (->), followed by some text -- all wrapped in double curly brackets. 

The following definition creates a snippet called [test](class:kwd) which is transformed into the text "This is a test snippet.". 

<code>\{\{test -> This is a test snippet.\}\}</code>

Once a snippet is defined _anywhere_ in the document, you can use its identifier wrapped in double curly brackets (<code>\{\{test}\}\}</code> in the previous example) anywhere in the document to reuse the specified text.

> %note%
> Remarks
> 
> * It doesn't matter where a snippet is defined. Snippets can be used anywhere in the document, before or after their definition.
> * When a document is compiled, both snippets _and snippets definitions_ are evaluated their body text.

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

Additionally, you can define your own custom fields via command-line parameters, using the [--field/](class:arg) dynamic parameter, like this:

> %terminal%
> hastyscribe my-document.md --field/product:HastyScribe --field/version:1.2.0

In this case it will be possible to access the [product](class:kwd) and [product](class:kwd) fields within [my-document.md](class:file) using <code>\{\{$product\}\}</code> and <code>\{\{$version\}\}</code>.

## Macros

If snippets are not enough, and you want to reuse chunks of _similar_ content, you can define substitution macros using the following syntax:

<code>\{#greet -> Hello, $1! Are you $2?#\}</code>

This defines a macro called [greet](class:kwd) that takes two parameters which will be substituted instead of [$1](class:kwd) and [$2](class:kwd). To use the macro, use the following syntax:

<code>\{#greet||Fabio||ready#\}</code>

> %note%
> Note
> 
> * Like snippets, macros can be multiline.
> * Spaces and newline character are preseved ad the start and end of parameters.
> * You can use snippets and fields within macros (but you cannot nest macros inside other macros).

{@ -syntax-inline.md || 1 @}

{@ -syntax-block.md || 1 @}
