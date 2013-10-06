import os, parseopt, strutils, times, markdown

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

# TODO handle invalid date errors

if metadata.date == "":
  metadata.date = getDateStr()

var date = metadata.date.split('-')

var timeinfo = TTimeInfo(year: date[0].parseInt, month: TMonth(date[1].parseInt), monthday: date[2].parseInt)

let document = """<!doctype html>
<html lang="en">
<head>
  <title>$title</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  $css
</head> 
<body>
  <div id="header">
    <h1>$title</h1>
  </div>
  <div id="toc">
    $toc
  </div>
  <div id="main">
$body
  </div>
  <div id="footer">
    <p>by <em>$author</em> &ndash; Generated with <a href="https://github.com/h3rald/hastyscribe/">HastyScribe</a> on <em>$date</em></p>
  </div>
</body>""" % ["title", metadata.title, "author", metadata.author, "date", timeinfo.format("MMMM d, yyyy"), "toc", metadata.toc, "css", css, "body", body]

output_file.writeFile(document)
