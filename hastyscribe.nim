import os, parseopt, strutils, markdown

# Source
const src_css = "assets/hastyscribe.css".slurp

proc style_tag(css): string =
  result = "<style>$1</style>" % [css]

let css = src_css.style_tag

### MAIN

var opt = initOptParser()

opt.next

if opt.kind != cmdArgument:
  quit()

# Input file name
let input_file = opt.key
let inputsplit = input_file.splitFile

# Output file name
let output_file = inputsplit.dir/inputsplit.name & ".htm"

let source = input_file.readFile

# Document Variables
var metadata = TMDMetaData(title:"", author:"", date:"")
let body = source.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata)

let document = """<!doctype html>
<html lang="en">
<head>
  <title>$title</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  <meta name="date" content="$date" scheme="YYYY-MM-DD">
  $css
</head> 
<body>
  <h1>$title</h1>
  <div id="toc">
    $toc
  </nav>
  <div>
$body
  </main>
  <div id="footer">
    <p>by $author &ndash; Generated with <a href="http://h3rald.com/hastyscribe/">HastyScribe</a></p>
  </div>
</body>""" % ["title", metadata.title, "author", metadata.author, "date", metadata.date, "toc", metadata.toc, "css", css, "body", body]

output_file.writeFile(document)
