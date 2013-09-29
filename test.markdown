% Test Document
% Fabio Cevasco
% 2013-09-16


## Lists

### Unordered

* test
* test
* test

### Ordered

1. First
2. Second
3 Third

### Definitions 

Term #1
: Definition #1
Term #2
: Definition #2

## Other

This is a paragraph, which is text surrounded by whitespace. Paragraphs can be on one 
line (or many), and can drone on for hours.  

Here is a Markdown link to [Warped](http://warpedvisions.org), and a literal . 
Now some SimpleLinks, like one to [google] (automagically links to are-you-
feeling-lucky). 

Now some inline markup like _italics_,  **bold**, and `code()`. Note that underscores in 
words are ignored in Markdown Extra.

> Blockquotes are like quoted text in email replies
>> And, they can be nested

And now some code:

    // Code is just text indented a bit
    which(is_easy) to_remember();

and fenced code:

~~~
def test
  puts "Hello!"
end
~~~


First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

## Notes

> %warning%
> Warning
> 
> Another test

> %note%
> Note
> 
> This is a relatively-long note
> on one paragraph, which should be near enough 100% width on mobile devices.

> %tip%
> Tip
> 
> Another test

> %important%
> Important
> 
> Another test

> %caution%
> CAUTION
>
> Test...

> %see-also%
> See Also
>
> Something else...

## Special Lists & Element Styling

> %tasks%
> ### Task List
> **To Do something...**
> ~~Done!~~

> %presence%
> ### Attendees
> **Kirk, James T.**
> **Spock**
> ~~Sulu, Hikaru~~
> ~~Uhura, Nyota~~

> %availability%
> ### Availability
> **Kirk, James T.**
> *Spock*
> ~~Sulu, Hikaru~~
> ~~Uhura, Nyota~~

> %priority%
> ### Priority List
> **High Priority**
> `Normal Priority`
> *Low Priority*

> %events%
> ### Event List
> **Action!**
> `Decision...`
> *Observation...*

> %status%
> ### Status List
> **Everything OK**
> `On hold/in progress`
> *Blocked!*
> ~~Cancelled...~~

> %org%
> ### Org Chart
> * Head of Such and Such
>   * Team Leader #1
>     * Team Member
>     * Team Member
>     * Team Member
>   * Team Leader #2
>     * Team Member
>     * Team Member
>     * Team Member

> %tags%
> ### Tags
> * Deadline: [E10/2013](class:deadline)
> * Bug: [123275](class:bug) [123275](class:feature) [123275](class:user-story) [121235](class:epic) [123275](class:task) [123275](class:test)
> * User: [Fabio Cevasco](class:person)
> * Tag: [reference](class:tag)
> * Flags: [danger!](class:red-flag) [possible problems](class:yellow-flag) [all good](class:green-flag)
> * Place: [Genoa](class:place)
> * Project: [HastyScribe](class:project)
> * OS: [Windows 8](class:windows) [iPhone](class:apple) [Galaxy S4](class:android) [Ubuntu](class:linux)
> * Currency: [2,000](class:usd) [2,000](class:eur) [2,000](class:gbp) [2,000](class:jpy) [2,000](class:cny) [2,000](class:krw) [2,000](class:inr) [2,000](class:btc)

> %links%
> ### Links 
> * <http://h3rald.com>
> * <http://github.com>
> * <http://www.linkedin.com>
> * <http://www.facebook.com>
> * <h3rald@h3rald.com>
> * [+01 0123456789](tel:+01 0123456789)
