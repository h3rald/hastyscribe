import 
  os, 
  parseopt2, 
  strutils, 
  sequtils,
  times, 
  pegs, 
  base64, 
  markdown, 
  tables,
  httpclient

import
  config,
  consts,
  utils


type
  HastyOptions* = object
    toc*: bool
    input*: string
    output*: string
    css*: string
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


proc initFields(fields: HastyFields): HastyFields =
  result = initTable[string, proc():string]()
  for key, value in fields.pairs:
    result[key] = value
  var now = getTime().getLocalTime()
  result["timestamp"] = proc():string =
    return $now.toTime.toSeconds().int
  result["date"] = proc():string =
    return now.format("yyyy-MM-dd")
  result["full-date"] = proc():string =
    return now.format("dddd, MMMM d, yyyy")
  result["long-date"] = proc():string =
    return now.format("MMMM d, yyyy")
  result["medium-date"] = proc():string =
    return now.format("MMM d, yyyy")
  result["short-date"] = proc():string =
    return now.format("M/d/yy")
  result["short-time-24"] = proc():string =
    return now.format("HH:mm")
  result["short-time"] = proc():string =
    return now.format("HH:mm tt")
  result["time-24"] = proc():string =
    return now.format("HH:mm:ss")
  result["time"] = proc():string =
    return now.format("HH:mm:ss tt")
  result["day"] = proc():string =
    return now.format("dd")
  result["month"] = proc():string =
    return now.format("MM")
  result["year"] = proc():string =
    return now.format("yyyy")
  result["short-day"] = proc():string =
    return now.format("d")
  result["short-month"] = proc():string =
    return now.format("M")
  result["short-year"] = proc():string =
    return now.format("yy")
  result["weekday"] = proc():string =
    return now.format("dddd")
  result["weekday-abbr"] = proc():string =
    return now.format("dd")
  result["month-name"] = proc():string =
    return now.format("MMMM")
  result["month-name-abbr"] = proc():string =
    return now.format("MMM")
  result["timezone-offset"] = proc():string =
    return now.format("zzz")
  result["timezone"] = proc():string =
    return now.format("ZZZ")

proc newHastyScribe*(options: HastyOptions, fields: HastyFields): HastyScribe =
  return HastyScribe(options: options, fields: initFields(fields), snippets: initTable[string, string](), macros: initTable[string, string](), document: "")

# Utility Procedures

proc embed_images(hs: var HastyScribe, dir: string) =
  let peg_img = peg"""
    image <- '<img' \s+ 'src=' ["] {file} ["]
    file <- [^"]+
  """
  var current_dir:string
  if dir.len == 0:
    current_dir = ""
  else:
    current_dir = dir & "/"
  type
    TImgTagStart = array[0..0, string]
  var doc = hs.document
  for img in findAll(hs.document, peg_img):
    var matches:TImgTagStart
    discard img.match(peg_img, matches)
    let imgfile = matches[0]
    let imgformat = imgfile.image_format
    var imgcontent = ""
    if imgfile.startsWith(peg"'data:'"): 
      continue
    elif imgfile.startsWith(peg"http[s]?'://'"):
      try:
        let client = newHttpClient()
        imgcontent = encode_image(client.getContent(imgfile), imgformat)
      except:
        stderr.writeLine "Warning: Unable to download '" & imgfile & "'"
        stderr.writeLine "  Reason: " & getCurrentExceptionMsg()
        stderr.writeLine "  -> Image will be linked instead"
        continue
    else:
      imgcontent = encode_image_file(current_dir & imgfile, imgformat)
    let imgrep = img.replace("\"" & img_file & "\"", "\"" & imgcontent & "\"")
    doc = doc.replace(img, imgrep)
  hs.document = doc

proc add_jump_to_top_links(hs: var HastyScribe) =
  hs.document = hs.document.replacef(peg"{'</h' [23456] '>'}", "<a href=\"#document-top\" title=\"Go to top\"></a>$1")


proc embed_fonts(): string=
  let fonts = @[
    create_font_face(hastyscribe_font, "HastyScribe", "normal", 400),
    create_font_face(fontawesome_font, "FontAwesome", "normal", 400),
    create_font_face(sourcecodepro_font, "Source Code Pro", "normal", 400),
    create_font_face(sourcesanspro_font,  "Source Sans Pro", "normal", 400),
    create_font_face(sourcesanspro_bold_font, "Source Sans Pro", "normal", 800),
    create_font_face(sourcesanspro_it_font, "Source Sans Pro", "italic", 400),
    create_font_face(sourcesanspro_boldit_font,  "Source Sans Pro", "italic", 800)
  ]
  return style_tag(fonts.join);

# Macro Definition:
# {{#test -> This is a $1}}
#
# Macro Usage:
# {{#test||simple test}}
proc parse_macros(hs: var HastyScribe) =
  let peg_macro_def = peg"""
    definition <- '{#' \s* {id} \s* '->' {@} '#}'
    id <- [a-zA-Z0-9_-]+
  """
  let peg_macro_instance = peg"""
    instance <- "{#" \s* {id} \s*  "||" \s* {@}  "#}"
    id <- [a-zA-Z0-9_-]+
  """
  var doc = hs.document
  for def in findAll(hs.document, peg_macro_def):
    var matches: array[0..1, string]
    discard def.match(peg_macro_def, matches)
    let id = matches[0].strip
    let value = matches[1].strip
    hs.macros[id] = value
    doc = doc.replace(def, "")
  for instance in findAll(doc, peg_macro_instance):
    var matches: array[0..1, string]
    discard instance.match(peg_macro_instance, matches)
    let id = matches[0].strip
    let value = matches[1].strip
    let params = value.split("||")
    if hs.macros.hasKey(id):
      try:
        doc = doc.replace(instance, hs.macros[id] % params)
      except:
        stderr.writeLine "Warning: Incorrect number of parameters specified for macro '$1'\n  -> Instance: $2" % [id, instance]
    else:
      stderr.writeLine "Warning: Macro '" & id & "' not defined."
      doc = doc.replace(instance, "")
  hs.document = doc

# Field Usage:
# {{$timestamp}}
proc parse_fields(hs: var HastyScribe) =
  let peg_field = peg"""
    field <- '{{' \s* '$' {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
  var doc = hs.document
  for field in hs.document.findAll(peg_field):
    var matches:array[0..0, string]
    discard field.match(peg_field, matches)
    var id = matches[0].strip
    if hs.fields.hasKey(id):
      doc = doc.replace(field, hs.fields[id]())
    else:
      stderr.writeLine "Warning: Field '" & id & "' not defined."
      doc = doc.replace(field, "")
  hs.document = doc

# Snippet Definition:
# {{test -> My test snippet}}
#
# Snippet Usage:
# {{test}}
proc parse_snippets(hs: var HastyScribe) =
  let peg_snippet_def = peg"""
    definition <- '{{' \s* {id} \s* '->' {@} '}}'
    id <- [a-zA-Z0-9_-]+
  """
  let peg_snippet = peg"""
    snippet <- '{{' \s* {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
  type
    TSnippetDef = array[0..1, string]
    TSnippet = array[0..0, string]
  var doc = hs.document
  for def in findAll(hs.document, peg_snippet_def):
    var matches:TSnippetDef
    discard def.match(peg_snippet_def, matches)
    var id = matches[0].strip
    var value = matches[1].strip(true, false)
    hs.snippets[id] = value
    doc = doc.replace(def, value)
  for snippet in findAll(hs.document, peg_snippet):
    var matches:TSnippet
    discard snippet.match(peg_snippet, matches)
    var id = matches[0].strip
    if hs.snippets[id] == nil:
      stderr.writeLine "Warning: Snippet '" & id & "' not defined."
      doc = doc.replace(snippet, "")
    else:
      doc = doc.replace(snippet, hs.snippets[id])
  hs.document = doc

proc compileFragment*(hs: var HastyScribe, input: string): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Parse fields, snippets, and macros
  hs.parse_fields()
  hs.parse_snippets()
  hs.parse_macros()
  # Process markdown
  hs.document = hs.document.md(MKD_EXTRA_FOOTNOTE or MKD_NOHEADER)
  return hs.document

proc compileDocument*(hs: var HastyScribe, input, dir: string): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Parse fields, snippets, and macros
  hs.parse_fields()
  hs.parse_snippets()
  hs.parse_macros()
  # Document Variables
  var 
    main_css_tag = stylesheet.style_tag
    user_css_tag = ""
    watermark_css_tag  = ""
    headings = " class=\"headings\""
    author_footer = ""
    title_tag = ""
    header_tag = ""
    toc = ""
    metadata = TMDMetaData(title:"", author:"", date:"", toc:"", css:"")
  # Process markdown
  hs.document = hs.document.md(MKD_DOTOC or MKD_EXTRA_FOOTNOTE, metadata)
  # Manage metadata
  if metadata.author != "":
    author_footer = "<span class=\"copy\"></span> " & metadata.author & " &ndash;"
  if metadata.title != "":
    title_tag = "<title>" & metadata.title & "</title>"
    header_tag = "<div id=\"header\"><h1>" & metadata.title & "</h1></div>"
  else:
    title_tag = ""
    header_tag = ""

  if hs.options.toc and metadata.toc != "":
    toc = "<div id=\"toc\">" & metadata.toc & "</div>"
  else:
    headings = ""
    toc = ""

  if not hs.options.css.isNil:
    user_css_tag = hs.options.css.readFile.style_tag

  if not hs.options.watermark.isNil:
    watermark_css_tag = watermark_css(hs.options.watermark)

  # Date parsing and validation
  var timeinfo: TimeInfo = getLocalTime(getTime())

  if parse_date(metadata.date, timeinfo) == false:
    discard parse_date(getDateStr(), timeinfo)

  hs.document = """<!doctype html>
<html lang="en">
<head>
  $title_tag
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  <meta name="generator" content="HastyScribe">
  $fonts_css_tag
  $main_css_tag
  $user_css_tag
  $internal_css_tag
  $watermark_css_tag
</head>
<body$headings>
  <div id="container">
    <a id="document-top"></a>
    $header_tag
    $toc
    <div id="main">
$body
    </div>
    <div id="footer">
      <p>$author_footer $date</p>
      <p><span>Powered by</span> <a href="https://h3rald.com/hastyscribe"><span class="hastyscribe"></span></a></p>
    </div>
  </div>
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "author_footer", author_footer, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "main_css_tag", main_css_tag, "user_css_tag", user_css_tag, "headings", headings, "body", hs.document,
"fonts_css_tag", embed_fonts(), "internal_css_tag", metadata.css, "watermark_css_tag", watermark_css_tag]
  hs.embed_images(dir)
  hs.add_jump_to_top_links()
  return hs.document

proc compile*(hs: var HastyScribe, input_file: string) =
  let inputsplit = input_file.splitFile
  var input = input_file.readFile
  var output: string

  if hs.options.output.isNil:
    output = inputsplit.dir/inputsplit.name & ".htm"
  else:
    output = hs.options.output

  if hs.options.fragment:
    hs.compileFragment(input)
  else:
    hs.compileDocument(input, inputsplit.dir)
  if output != "-":
    output.writeFile(hs.document)
  else:
    stdout.write(hs.document)

### MAIN

when isMainModule:
  let usage = "  HastyScribe v" & version & " - Self-contained Markdown Compiler" & """

  (c) 2013-2016 Fabio Cevasco

  Usage:
    hastyscribe <markdown_file_or_glob> [options]

  Arguments:
    markdown_file_or_glob   The markdown (or glob expression) file to compile into HTML.
  Options:
    --field/<field>=<value> Define a new field called <field> with value <value>.
    --notoc                 Do not generate a Table of Contents.
    --user-css=<file>       Insert contents of <file> as a CSS stylesheet.
    --output-file=<file>    Write output to <file>.
                            (Use "--output-file=-" to output to stdout)
    --watermark=<file>      Use the image in <file> as a watermark.
    --fragment              If specified, an HTML fragment will be generated, without 
                            embedding images, fonts, or stylesheets. """
    

  var input = ""
  var files = newSeq[string](0)
  var options = HastyOptions(toc: true, output: nil, css: nil, watermark: nil, fragment: false)
  var fields = initTable[string, proc():string]()

  # Parse Parameters

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      input = key
    of cmdLongOption:
      case key
      of "notoc":
        options.toc = false
      of "user-css":
        options.css = val
      of "watermark":
        options.watermark = val
      of "output-file":
        options.output = val
      of "fragment":
        options.fragment = true
      else:
        if key.startsWith("field/"):
          let val = val
          fields[key.replace("field/", "")] = proc(): string =
            return val
        discard
    else: 
      discard

  if input == "":
    quit(usage, 1)
  elif options.css == "":
    quit(usage, 4)
  elif options.output == "":
    quit(usage, 5)
  elif options.watermark == "":
    quit(usage, 6)


  for file in walkFiles(input):
    files.add(file)

  if files.len == 0:
    quit("Error: \"$1\" does not match any file" % [input], 2)
  else:
    var hs = newHastyScribe(options, fields)
    try:
      for file in files:
        hs.compile(file)
    except IOError:
      let msg = getCurrentExceptionMsg()
      quit("Error: $1" % [msg], 3)
