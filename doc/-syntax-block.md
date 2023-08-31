# Block-level Formatting

## Headings

Headings can be specified simply by prepending [#](class:kwd)s to text, as follows: 

    # Heading 1
    ## Heading 2
    ### Heading 3
    #### Heading 4
    ##### Heading 5
    ###### Heading 6

> %note%
> Note
> 
> If you use [Document Headers](#Document-Headers), A [H1](class:kwd) is used for the title of the {{hs}} document. Within the document, start using headings from [H2](class:kwd).

## Tables

{{hs}} supports [PHP Markdown Extra][pme] table syntax using pipes and dashes.

{{input-text}}

~~~
Column Header 1 | Column Header 2 | Column Header 3 
----------------|-----------------|----------------
Cell 1,1        | Cell 1,2        | Cell 1, 3
Cell 2,1        | Cell 2,2        | Cell 2, 3
Cell 3,1        | Cell 3,2        | Cell 3, 3
~~~

{{output-text}}

Column Header 1 | Column Header 2 | Column Header 3 
----------------|-----------------|----------------
Cell 1,1        | Cell 1,2        | Cell 1, 3
Cell 2,1        | Cell 2,2        | Cell 2, 3
Cell 3,1        | Cell 3,2        | Cell 3, 3

> %note%
> Note
> 
> Multi-row cells are not supported. If you need more complex tables, use HTML code instead.


> %sidebar%
> Responsive Tables
> 
> To make tables responsive, put them in a _responsive_ block, like in the previous example. The [responsive](class:kwd) class causes a table not to shrink and makes it scrollable horizontally on small devices.  

## Block Quotes

Block quotes can be created simply by prepending a [>](class:kwd) to a line, and they can be nested by prepending additional [>](class:kwd)s.

{{input-text}}

~~~
> This is a block quote.
> > This is a nested quote. 
~~~

{{output-text}}

> This is a block quote.
> > This is a nested quote. 

## Code Blocks

To format a block of source code, indent it by at least four spaces. Here's the result:

    proc encode_image_file*(file, format): string =
      if (file.existsFile):
        let contents = file.readFile
        return encode_image(contents, format)
      else: 
        echo("Warning: image '"& file &"' not found.")
        return file

Alternatively, you can also use Github-style fenced blocks, by adding three tildes (~~~) or backticks (```) before and after the source code. 

> %warning%
> Warning
> 
> {{hs}} does not support syntax highlighting for code blocks. To do so, it would require Javascript and {{hs}} is currently kept purposedly "Javascript-free".


## Images

{{input-text -> The following HastyScribe Markdown code:}}

~~~
![HastyScribe Logo](./images/hastyscribe.png =221x65)
~~~

{{output-text -> Produces the following output:}}

![HastyScribe Logo](./images/hastyscribe.png =221x65)

> %tip%
> Tip
> 
> You can use URL placeholders for images as well, exactly like for links.

> %warning%
> Limitations on automatic image download
> 
> {{hs}} will attempt to download all HTTP image links. Note that:
> 
> * If no response is received within 5 seconds, the download will be aborted.
> * Connecting through a proxy is currently not supported.
> * To download an image via HTTPS, you must explicitly recompile {{hs}} with [-d:ssl](class:kwd) and OpenSSL must be installed on your system.
> 
> If {{hs}} is unable to download an image, it will leave it linked.

## Details

{{input-text}}

~~~
<details>
<summary>Details</summary>
The `details` element can be used to create a disclosure element whose contents are only visible when the element is toggled open.
</details>
~~~

{{output-text}}

<details>
<summary>Details</summary>
The `details` element can be used to create a disclosure element whose contents are only visible when the element is toggled open.
</details>

## Footnotes

{{input-text}}

~~~
This is some text[^1]

[^1]: This is a footnote!
~~~

{{output-text}}

This is some text[^1]

[^1]: This is a footnote!


{@ -syntax-block-lists.md || 1 @}

{@ -syntax-block-classes.md || 1 @}
