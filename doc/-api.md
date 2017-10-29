# Nim API

Besides its command libe, you can also import {{hs}} as a library within your [Nim](https://nim-lang.org) program.

## Types

{{hs}} exposes the following Nim types:

```
HastyOptions* = object
  toc*: bool
  input*: string
  output*: string
  css*: string
  js*: string
  watermark*: string
  fragment*: bool

HastyFields* = Table[string, proc():string]

HastySnippets* = Table[string, string]

HastyMacros* = Table[string, string]

HastyScribe* = object
  options: HastyOptions
  fields: HastyFields
  snippets: HastySnippets
  macros: HastyMacros
  document: string
```

## Procs

{{hs}} exposes the following [proc](class:kwd)s.

### newHastyScribe

     proc newHastyScribe*(options: HastyOptions, fields: HastyFields): HastyScribe

Instantiates a new {{hs}} object.

### dump

     proc dump*(hs: var HastyScribe, data="all", dest=".")

Saves linked resources to the [dest](class:dir) directory.

[data](class:kwd) can be set to one of the following values:

all
: Dumps all resource files.
styles
: Dumps all stylesheet files.
fonts
: Dumps all font files.

### compileFragment

     proc compileFragment*(hs: var HastyScribe, input, dir: string, toc = false): string {.discardable.}

Compiles the [input](class:kwd) markdown text into an HTML fragment, without embedding stylesheets or fonts. [dir](class:kwd) identifies the directory containing the input text (it is only used to resolve transclusions).

### compileDocument

     proc compileDocument*(hs: var HastyScribe, input, dir: string): string {.discardable.}

Compiles the [input](class:kwd) markdown text into a self-contained HTML document, embedding stylesheets and fonts. [dir](class:kwd) identifies the directory containing the input text (it is only used to resolve transclusions).

### compile

     proc compile*(hs: var HastyScribe, input_file: string)

Compiles the markdown file [input\_file](class:kwd) into a self-contained HTML document.
