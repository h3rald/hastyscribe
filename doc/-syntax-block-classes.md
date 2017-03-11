# Class Blocks 

## Notes

[Discount][discount] supports the definition of _class blocks_: [div](class:kwd)s with a class attribute. The syntax is very similar to the one used for [block quotes](#Block.Quotes), with the addition of the class name wrapped in [%](class:kwd)s on the first line. 

In {{hs}}, this syntax is used to produce notes, [tips](#Tips), [warmings](#Warnings), [sidebars](#Sidebars) and [terminal sessions](#Terminal.Sessions).

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

## Tips

Tips are used for optional information that can help the user in some way. 

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

## Warnings

Warnings are used for important information the user should not overlook. 

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

## Sidebars

Sidebars are used for digressions and asides. 

{{input-text}}

~~~
> %sidebar%
> This is a _sidebar_
> 
> Although not always placed on the side of the page, _sidebars_ contain 
> additional content and asides.
~~~

{{output-text}}

> %sidebar%
> This is a _sidebar_
> 
> Although not always placed on the side of the page, _sidebars_ contain additional content and asides.


## Terminal Sessions

Terminal sessions are used to display commands entered in a terminal, in sequence, without displaying their output. 

{{input-text}}

~~~
> %terminal%
> 
> cd src
> 
> ./configure
> 
> make && sudo make install
~~~

{{output-text}}

> %terminal%
> cd src
> 
> ./configure
> 
> make && sudo make install

If commands must be executed as a super-user, use the [terminal-su](class:kwd) class instead:

{{input-text}}

~~~
> %terminal-su%
> 
> shutdown -h now
~~~

{{output-text}}

> %terminal-su%
> 
> shutdown -h now

