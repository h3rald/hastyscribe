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

Badges are shorthands for [Icons](#Icons) formatted with different colors. To add a _badge_ to some inline text, use the corresponding class among those listed in the following table. For example, the following code:

    [Genoa, Italy](class:badge-geo)

produces the following result:

[Genoa, Italy](class:badge-geo)

{{hs}} currently supports the following badges:

> %responsive%
> Class                      | Badge                              | Class                     | Badge 
> ---------------------------|------------------------------------|---------------------------|-----------------------------
> `badge-todo`               | [](class:badge-todo)               |`badge-user`               | [](class:badge-user)
> `badge-fixme`              | [](class:badge-fixme)              |`badge-tag`                | [](class:badge-tag) 
> `badge-deadline`           | [](class:badge-deadline)           |`badge-tags`               | [](class:badge-tags) 
> `badge-comment`            | [](class:badge-comment)            |`badge-attachment`         | [](class:badge-attachment)
> `badge-urgent`             | [](class:badge-urgent)             |`badge-bug`                | [](class:badge-bug)
> `badge-verify`             | [](class:badge-verify)             |`badge-geo`                | [](class:badge-geo)
> `badge-project`            | [](class:badge-project)            |`badge-square`             | [](class:badge-square) 
> `badge-star`               | [](class:badge-star)               |`badge-check`              | [](class:badge-check) 
> `badge-heart`              | [](class:badge-heart)              |`badge-rss`                | [](class:badge-rss)               
> `badge-lock`               | [](class:badge-lock)               |`badge-danger`             | [](class:badge-danger)
> `badge-unlock`             | [](class:badge-unlock)             |`badge-question`           | [](class:badge-question)
> `badge-folder`             | [](class:badge-folder)             |`badge-flag`               | [](class:badge-flag)
> `badge-story`              | [](class:badge-story)              |`badge-feature`            | [](class:badge-feature)
> `badge-add`                | [](class:badge-add)                |`badge-remove`             | [](class:badge-remove)
> `badge-time`               | [](class:badge-time)               |`badge-date`               | [](class:badge-date)
> `badge-html5`              | [](class:badge-html5)              |`badge-css3`               | [](class:badge-css3)
> `badge-apple`              | [](class:badge-apple)              |`badge-windows`            | [](class:badge-windows)
> `badge-linux`              | [](class:badge-linux)              |`badge-android`            | [](class:badge-android)
> `badge-freebsd`            | [](class:badge-freebsd)            |`badge-aws`                | [](class:badge-aws)
> `badge-idea`               | [](class:badge-idea)               |`badge-link`               | [](class:badge-link)
> `badge-chrome`             | [](class:badge-chrome)             |`badge-firefox`            | [](class:badge-firefox)
> `badge-ie`                 | [](class:badge-ie)                 |`badge-edge`               | [](class:badge-edge)
> `badge-safari`             | [](class:badge-safari)             |`badge-opera`              | [](class:badge-opera)
> `badge-php`                | [](class:badge-php)                |`badge-erlang`             | [](class:badge-erlang)
> `badge-python`             | [](class:badge-python)             |`badge-java`               | [](class:badge-java)
> `badge-nodejs`             | [](class:badge-nodejs)             |`badge-js`                 | [](class:badge-js)
> `badge-toggle-on`          | [](class:badge-toggle-on)          |`badge-toggle-off`         | [](class:badge-toggle-off)
> `badge-debian`             | [](class:badge-debian)             |`badge-fedora`             | [](class:badge-fedora)
> `badge-centos`             | [](class:badge-centos)             |`badge-suse`               | [](class:badge-suse)
> `badge-redhat`             | [](class:badge-redhat)             |`badge-ubuntu`             | [](class:badge-ubuntu)
> `badge-rust`               | [](class:badge-rust)               |`badge-go`                 | [](class:badge-go)
> `badge-rpi`                | [](class:badge-rpi)                |`badge-markdown`           | [](class:badge-markdown)
> `badge-react`              | [](class:badge-react)              |`badge-angular`            | [](class:badge-angular)
> `badge-vue`                | [](class:badge-vue)                |`badge-code`               | [](class:badge-code)
> `badge-address`            | [](class:badge-address)            |`badge-org`                | [](class:badge-org)
> `badge-toxic`              | [](class:badge-toxic)              |`badge-network`            | [](class:badge-network)
> `badge-upload`             | [](class:badge-upload)             |`badge-download`           | [](class:badge-download)


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
> * [fabiocevasco](https://it.linkedin.com/in/fabiocevasco)

