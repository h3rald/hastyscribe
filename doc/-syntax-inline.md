# Inline Formatting 

The following table lists all the most common ways to format inline text: 

> %responsive%
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
> `A [.md](class:ext) file`                           | A [.md](class:ext) file
> `[my_markdown_file.md](class:file) file`            | [my_markdown_file.md](class:file) file

> %tip%
> Tip
> 
> The [kwd](class:kwd), [opt](class:kwd), [file](class:kwd), [dir](class:kwd), [arg](class:kwd), [tt](class:kwd) and [cmd](class:kwd) classes are all rendered as inline monospace text. [kwd](class:kwd) and [ext](class:ext) are also rendered in bold.


## SmartyPants Substitutions

Special characters can be easily entered using some special character sequences.

{{hs}} supports all the sequences supported by [Discount][discount]:

* <code>`` text‘’</code> &rarr; “text”.
* `"double-quoted text"` &rarr; “double-quoted text”
* `'single-quoted text'` &rarr; ‘single-quoted text’
* `don't` &rarr; don’t. as well as anything-else’t. (But foo'tbar is just foo'tbar.)
* `it's` &rarr; it’s, as well as anything-else’s (except not foo'sbar and the like.)
* `(tm)` &rarr; ™
* `(r)` &rarr; ®
* `(c)` &rarr; ©
* `1/4th` &rarr; 1/4th. Same goes for 1/2 and 3/4.
* `...` or `. . .` &rarr; …
* `---` &rarr; —
* `--` &rarr; –
* `A^B` becomes A^B. Complex superscripts can be enclosed in brackets, so `A^(B+2)` &rarr; A^(B+2).


## Icons

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

## Badges

Badges are normally just shorthands for [Icons](#Icons) formatted with different colors. To add a _badge_ to some inline text, use the corresponding class among those listed in the following table. For example, the following code:

    [Genoa, Italy](class:geo)

produces the following result:

[Genoa, Italy](class:geo)

{{hs}} currently supports the following badges:

> %responsive%
> Class                | Badge                        | Class               | Badge 
> ---------------------|------------------------------|--------------------------------------------
> `todo`               | [](class:todo)               |`user`               | [](class:user)
> `fixme`              | [](class:fixme)              |`tag`                | [](class:tag) 
> `deadline`           | [](class:deadline)           |`tags`               | [](class:tags) 
> `draftcomment`       | [](class:draftcomment)       |`attachment`         | [](class:attachment)
> `urgent`             | [](class:urgent)             |`bug`                | [](class:bug)
> `verify`             | [](class:verify)             |`geo`                | [](class:geo)
> `project`            | [](class:project)            |`eur`                | [](class:eur)
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
> `email`              | [](class:email)              |`website`            | [](class:website)
> `phone`              | [](class:phone)              |`fax`                | [](class:fax)
> `tm`                 | [](class:tm)                 |`reg`                | [](class:reg)
> `copy`               | [](class:copy)               |`red-flag`           | [](class:red-flag)
> `green-flag`         | [](class:green-flag)         |`yellow-flag`        | [](class:yellow-flag)
> `story`              | [](class:story)              |`feature`            | [](class:feature)
> `add`                | [](class:add)                |`remove`             | [](class:remove)
> `time`               | [](class:time)               |`date`               | [](class:date)
> `html5`              | [](class:html5)              |`css3`               | [](class:css3)
> `apple`              | [](class:apple)              |`windows`            | [](class:windows)
> `linux`              | [](class:linux)              |`android`            | [](class:android)
> `idea`               | [](class:idea)               |`link`               | [](class:link)
> `chrome`             | [](class:chrome)             |`firefox`            | [](class:firefox)
> `ie`                 | [](class:ie)                 |`edge`               | [](class:edge)
> `safari`             | [](class:safari)             |`opera`              | [](class:opera)
> `sticky`             | [](class:sticky)             |`bluetooth`          | [](class:bluetooth)
> `wifi`               | [](class:wifi)               |`signal`             | [](class:signal)
> `usb`                | [](class:usb)                |`print`              | [](class:print)
> `php`                | [](class:php)                |`erlang`             | [](class:erlang)
> `python`             | [](class:python)             |`java`               | [](class:java)
> `nodejs`             | [](class:nodejs)             |`aws`                | [](class:aws)
> `desktop`            | [](class:desktop)            |`laptop`             | [](class:laptop)
> `mobile`             | [](class:mobile)             |`tablet`             | [](class:tablet)
> `rss`                | [](class:rss)                |`paperclip`          | [](class:paperclip)
> `toggle-on`          | [](class:toggle-on)          |`toggle-off`         | [](class:toggle-off)
> `paypal`             | [](class:paypal)             |`stripe`             | [](class:stripe)
> `amex`               | [](class:amex)               |`jcb`                | [](class:jcb)
> `visa`               | [](class:visa)               |`mastercard`         | [](class:mastercard)
> `diners`             | [](class:diners)             |`discover`           | [](class:discover)
> `apple-pay`          | [](class:apple-pay)          |`amazon-pay`         | [](class:amazon-pay)

## HastyScribe Logo

To display the {{hs}} logo, use the [hastyscribe](class:kwd) class, like this:

`[](class:hastyscribe)` &rarr; [](class:hastyscribe)

## Anchors

You can define HTML anchors inline by wrapping their ID in hashes. For example, the following code:

     Some text goes here. \#some_text\#

Is converted to:

     Some text goes here. <a id="some_text"></a>

> %note%
> Note
> 
> * Anchor markup must be preceded by at least one space.
> * IDs must start with a letter, and can contain letters, numbers, and any of the following characters: `_` `-` `.` `:` 

## Links

> %responsive%
> Source                                  | Output
> ----------------------------------------|------------
> `[H3RALD](https://h3rald.com/)`         | [H3RALD](https://h3rald.com/)
> `[H3RALD](https://h3rald.com/ "H3RALD")`| [H3RALD](https://h3rald.com/ "H3RALD")
> `<https://h3rald.com>`                  | <https://h3rald.com> 

Additionally, you can define placeholders for URLs and link titles, like this:

`[h3rald]: https://h3rald.com/ "Fabio Cevasco's Web Site"`

And use them in hyperlinks (note the usage of square brackets instead of round brackets):

`[H3RALD][h3rald]`

> %sidebar%
> Link Icons
> 
> {{hs}} automatically adds an envelope icon to email links, an arrow icon to links to external web sites, and logo icons to links to well-known web sites:
> 
> * [h3rald@h3rad.com](mailto:h3rald@h3rald.com)
> * [@h3rald](https://twitter.com/h3rald)
> * [fabiocevasco](http://it.linkedin.com/in/fabiocevasco)

