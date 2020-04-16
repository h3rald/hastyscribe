# Lists

## Unordered Lists

{{input-text}}

~~~
* An item
* Another item
* And another...
~~~

{{output-text}}

* An item
* Another item
* And another...

## Ordered Lists

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

## Alphabetical Lists

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

## Checklists
{{input-text}}

~~~
- [ ] Do something
- [ ] Do something else
- [x] Done!
~~~

{{output-text}}

- [ ] Do something
- [ ] Do something else
- [x] Done!

## Unstyled Lists

{{input-text}}

~~~
> %unstyled%
> * An item
> * Another item
> * And another...
~~~

{{output-text}}

> %unstyled%
> * An item
> * Another item
> * And another...


## Nested Lists

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

## Definition Lists

In some cases you may want to write a list of terms and their corresponding definitions. You could use an ordinary unordered list, but semantically speaking the _proper_ type of list to use in this case is a definition list.

{{input-text}}

~~~
unordered list
: A list for unordered items. Also called _bulleted list_.
ordered list 
: A list for ordered items. Also called _numbered list_.
alphabetical list
: Technically speaking just an ordered list, but formatted with letters instead 
  of numbers
definition list
: A list of terms and definitions.
~~~

{{output-text}}

unordered list
: A list for unordered items. Also called _bulleted list_.
ordered list 
: A list for ordered items. Also called _numbered list_.
alphabetical list
: Technically speaking just an ordered list, but formatted with letters instead
  of numbers
definition list
: A list of terms and definitions.

Alternatively, you can write the above definition list as follows:

~~~
=unordered list=
  A list for unordered items. Also called _bulleted list_.
=ordered list=
  A list for ordered items. Also called _numbered list_.
=alphabetical list=
  Technically speaking just an ordered list, but formatted with letters instead
  of numbers
=definition list=
  A list of terms and definitions.
~~~


