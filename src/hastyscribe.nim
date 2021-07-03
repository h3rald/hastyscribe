import 
  os, 
  parseopt, 
  strutils, 
  times, 
  pegs, 
  tables,
  httpclient,
  logging

import
  ../packages/niftylogger,
  hastyscribepkg/markdown, 
  hastyscribepkg/config,
  hastyscribepkg/consts,
  hastyscribepkg/utils

export
  consts


when defined(discount):
  {.passL: "-L../packages/discount".}
  {.passL: "-lmarkdown".}
else:
  import os
  when dirExists("src/hastyscribepkg/vendor"):
    {.passL: "-Lsrc/hastyscribepkg/vendor".}
  else:
    {.passL: "-Lhastyscribepkg/vendor".}
  when defined(macosx):
    {.passL: "-lmarkdown_macosx_x64".}
  when defined(windows):
    {.passL: "-lmarkdown_windows_x64".}
  when defined(linux):
    when defined(arm):
      {.passL: "-lmarkdown_linux_arm".}
    when defined(i386):
      {.passL: "-lmarkdown_linux_x86".}
    when defined(amd64):
      {.passL: "-lmarkdown_linux_x64".}

type
  HastyOptions* = object
    toc*: bool
    input*: string
    output*: string
    css*: string
    js*: string
    watermark*: string
    fragment*: bool
  HastyFields* = Table[string, string]
  HastySnippets* = Table[string, string]
  HastyMacros* = Table[string, string]
  HastyScribe* = object
    options: HastyOptions
    fields: HastyFields
    snippets: HastySnippets
    macros: HastyMacros
    document: string

if logging.getHandlers().len == 0:
  newNiftyLogger().addHandler()

proc initFields(fields: HastyFields): HastyFields {.gcsafe.} =
  result = initTable[string, string]()
  for key, value in fields.pairs:
    result[key] = value
  var now = getTime().local()
  result["timestamp"] = $now.toTime.toUnix().int
  result["date"] = now.format("yyyy-MM-dd")
  result["full-date"] = now.format("dddd, MMMM d, yyyy")
  result["long-date"] = now.format("MMMM d, yyyy")
  result["medium-date"] = now.format("MMM d, yyyy")
  result["short-date"] = now.format("M/d/yy")
  result["short-time-24"] = now.format("HH:mm")
  result["short-time"] = now.format("HH:mm tt")
  result["time-24"] = now.format("HH:mm:ss")
  result["time"] = now.format("HH:mm:ss tt")
  result["day"] = now.format("dd")
  result["month"] = now.format("MM")
  result["year"] = now.format("yyyy")
  result["short-day"] = now.format("d")
  result["short-month"] = now.format("M")
  result["short-year"] = now.format("yy")
  result["weekday"] = now.format("dddd")
  result["weekday-abbr"] = now.format("dd")
  result["month-name"] = now.format("MMMM")
  result["month-name-abbr"] = now.format("MMM")
  result["timezone-offset"] = now.format("zzz")

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
    var imgformat = imgfile.image_format
    if imgformat == "svg":
      imgformat = "svg+xml"
    var imgcontent = ""
    if imgfile.startsWith(peg"'data:'"): 
      continue
    elif imgfile.startsWith(peg"'http' 's'? '://'"):
      try:
        let client = newHttpClient()
        imgcontent = encode_image(client.getContent(imgfile), imgformat)
      except:
        warn "Unable to download '" & imgfile & "'"
        warn "  Reason: " & getCurrentExceptionMsg()
        warn "  -> Image will be linked instead"
        continue
    else:
      imgcontent = encode_image_file(current_dir & imgfile, imgformat)
    let imgrep = img.replace("\"" & img_file & "\"", "\"" & imgcontent & "\"")
    doc = doc.replace(img, imgrep)
  hs.document = doc

proc embed_fonts(): string=
  let fonts = @[
    create_font_face(hastyscribe_font, "HastyScribe", "normal", 400),
    create_font_face(fa_solid_font, "Font Awesome 5 Free", "normal", 900),
    create_font_face(fa_brands_font, "Font Awesome 5 Brands", "normal", 400),
    create_font_face(sourcecodepro_font, "Source Code Pro", "normal", 400),
    create_font_face(sourcecodepro_it_font, "Source Code Pro", "italic", 400),
    create_font_face(sourcecodepro_bold_font, "Source Code Pro", "normal", 700),
    create_font_face(sourcecodepro_boldit_font, "Source Code Pro", "italic", 700),
    create_font_face(sourcesanspro_font,  "Source Sans Pro", "normal", 400),
    create_font_face(sourcesanspro_bold_font, "Source Sans Pro", "normal", 700),
    create_font_face(sourcesanspro_it_font, "Source Sans Pro", "italic", 400),
    create_font_face(sourcesanspro_boldit_font,  "Source Sans Pro", "italic", 700)
  ]
  return style_tag(fonts.join);

proc handleYamlMetadata*(contents: var string, metadata: var Table[string,string]): bool =
  ## If the document starts with YAML Front Matters then defined metadata is 
  ## returned in the metadata table as key value pairs
  ## and the YAML section is removed from the contents 
  result = false
  let peg_yaml = peg"""
    definition <- ^'---' \n {line+} '---' \n
    line <- \s* id \s* ':' \s* @ \n
    id <- [a-zA-Z0-9_-]+
  """
  var matches: array[0..0, string] 
  let (s, e) = contents.findBounds(peg_yaml, matches)
  # the pattern must start at the beginning of the file
  if s == 0:
    result = true
    # eat whole YAML section from the content and parse key value pairs
    contents.delete(0, e)
    let yaml = matches[0]
    let peg_key_value = peg"\s* {[a-zA-Z0-9_-]+} \s* ':' \s* {@} \n"
    for key_value in yaml.findAll(peg_key_value):
      var matches: array[0..1, string]
      discard key_value.match(peg_key_value, matches)
      let key = matches[0].strip
      let value = matches[1].strip
      if metadata.hasKey(key):
        warn "Key $1 already defined with value $2"% [key, metadata[key]]
      else:
        metadata[key] = value

proc preprocess*(hs: var HastyScribe, document, dir: string, offset = 0): string

proc applyHeadingOffset(contents: string, offset: int): string =
  if offset == 0:
    return contents
  let peg_heading = peg"""heading <- (^ / \n){'#'+}"""
  var handleHeading =  proc (index: int, count: int, matches: openArray[string]): string =
    let heading = matches[0]
    result = "\n" & "#".repeat(heading.len + offset)
  return contents.replace(peg_heading, handleHeading)

# Transclusion with heading offset:
# {@ some/file.md || 1 @}
proc parse_transclusions(hs: var HastyScribe, document: string, dir = "", offset = 0): string =
  result = document.applyHeadingOffset(offset)
  let peg_transclusion = peg"""
    transclusion <- '{\@' \s* {path} \s*  '||' \s* {offset} \s* '\@}'
    path <- [^|]+
    offset <- [0-5]
  """
  var cwd = dir
  if cwd != "":
    cwd = cwd & "/"
  for transclusion in document.findAll(peg_transclusion):
    var matches: array[0..1, string]
    discard transclusion.match(peg_transclusion, matches)
    let path = cwd & matches[0].strip
    let value = matches[1].strip
    let offset = value.split("||")[0].parseInt() + offset
    if path.fileExists():
      let fileInfo = path.splitFile()
      var contents, s = ""
      var delimiter = 0
      var f:File
      discard f.open(path)
      # Ignore headers
      try:
        discard f.readLine(s)
        if not s.startsWith("----"):
          delimiter = 2
          contents &= s&"\n"
        else:
          delimiter = 1
        while f.readLine(s):
          if delimiter >= 2:
            contents &= s&"\n"
          else:
            if s.startsWith("----"):
              delimiter.inc
      except:
        discard
      f.close()
      result = result.replace(transclusion, hs.parse_transclusions(contents, fileInfo.dir, offset))
    else:
      warn "File '$1' not found" % [path]
      result = result.replace(transclusion, "")

# Macro Definition:
# {#test -> This is a $1}
#
# Macro Usage:
# {#test||simple test}
proc parse_macros(hs: var HastyScribe, document: string): string =
  let peg_macro_def = peg"""
    definition <- '{#' \s* {id} \s* deftype {@} '#}'
    deftype <- '->' / '=>'
    id <- [a-zA-Z0-9_-]+
  """
  let peg_macro_instance = peg"""
    instance <- "{#" \s* {id} \s*  "||" \s* {@}  "#}"
    id <- [a-zA-Z0-9_-]+
  """
  result = document
  for def in document.findAll(peg_macro_def):
    var matches: array[0..1, string]
    discard def.match(peg_macro_def, matches)
    let id = matches[0].strip
    let value = matches[1].strip
    hs.macros[id] = value
    result = result.replace(def, "")
  for instance in findAll(result, peg_macro_instance):
    var matches: array[0..1, string]
    discard instance.match(peg_macro_instance, matches)
    let id = matches[0].strip
    let value = matches[1].strip
    let params = value.split("||")
    if hs.macros.hasKey(id):
      try:
        result = result.replace(instance, hs.macros[id] % params)
      except:
        warn "Incorrect number of parameters specified for macro '$1'\n  -> Instance: $2" % [id, instance]
    else:
      warn "Macro '" & id & "' not defined."
      result = result.replace(instance, "")

# Field Usage:
# {{$timestamp}}
proc parse_fields(hs: var HastyScribe, document: string): string {.gcsafe.} =
  let peg_field = peg"""
    field <- '{{' \s* '$' {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
  result = document
  for field in document.findAll(peg_field):
    var matches:array[0..0, string]
    discard field.match(peg_field, matches)
    var id = matches[0].strip
    if hs.fields.hasKey(id):
      result = result.replace(field, hs.fields[id])
    else:
      warn "Field '" & id & "' not defined."
      result = result.replace(field, "")

# Snippet Definition:
# {{test -> My test snippet}}
#
# Snippet Usage:
# {{test}}
proc parse_snippets(hs: var HastyScribe, document: string): string =
  let peg_snippet_def = peg"""
    definition <- '{{' \s* {id} \s* {deftype} {@} '}}'
    deftype <- '->' / '=>'
    id <- [a-zA-Z0-9_-]+
  """
  let peg_snippet = peg"""
    snippet <- '{{' \s* {id} \s* '}}'
    id <- [a-zA-Z0-9_-]+
  """
  type
    TSnippetDef = array[0..2, string]
    TSnippet = array[0..0, string]
  result = document
  for def in document.findAll(peg_snippet_def):
    var matches:TSnippetDef
    discard def.match(peg_snippet_def, matches)
    var id = matches[0].strip
    var value = matches[2].strip(true, false)
    hs.snippets[id] = value
    if matches[1] == "=>":
      value = ""
    result = result.replace(def, value)
  for snippet in document.findAll(peg_snippet):
    var matches:TSnippet
    discard snippet.match(peg_snippet, matches)
    var id = matches[0].strip
    if hs.snippets.hasKey(id):
      result = result.replace(snippet, hs.snippets[id])
    else:
      warn "Snippet '" & id & "' not defined."
      result = result.replace(snippet, "")

# Substitute escaped brackets or hashes *after* preprocessing
proc remove_escapes(hs: var HastyScribe, document: string): string =
  result = document
  for lb in document.findAll(peg"'\\{'"):
    result = result.replace(lb, "{")
  for rb in document.findAll(peg"'\\}'"):
    result = result.replace(rb, "}")
  for h in document.findAll(peg"'\\#'"):
    result = result.replace(h, "#")

proc parse_anchors(hs: var HastyScribe, document: string): string =
  result = document
  let peg_anchor = peg"""
    anchor <- \s '#' {id} '#' 
    id <- [a-zA-Z][a-zA-Z0-9:._-]+
  """
  for anchor in document.findAll(peg_anchor):
    var matches:array[0..0, string]
    discard anchor.match(peg_anchor, matches)
    var id = matches[0]
    result = result.replace(anchor, " <a id=\""&id&"\"></a>")

proc preprocess*(hs: var HastyScribe, document, dir: string, offset = 0): string = 
  result = hs.parse_transclusions(document, dir, offset)
  result = hs.parse_fields(result)
  result = hs.parse_snippets(result)
  result = hs.parse_macros(result)
  result = hs.parse_anchors(result)
  result = hs.remove_escapes(result)

# Public API

proc dump*(hs: var HastyScribe, data="all", dest=".") =
  if data == "all" or data == "styles":
      (dest/"hastyscribe.css").writeFile(stylesheet)
  if data == "all" or data == "fonts":
      (dest/"SourceCodePro-Regular.ttf.woff").writeFile(sourcecodepro_font)
      (dest/"SourceSansPro-Regular.ttf.woff").writeFile(sourcesanspro_font)
      (dest/"SourceSansPro-Bold.ttf.woff").writeFile(sourcesanspro_bold_font)
      (dest/"SourceSansPro-BoldIt.ttf.woff").writeFile(sourcesanspro_bold_it_font)
      (dest/"SourceSansPro-It.ttf.woff").writeFile(sourcesanspro_it_font)
      (dest/"fa-solid-900.woff").writeFile(fa_solid_font)
      (dest/"fa-brands-400.woff").writeFile(fa_brands_font)
      (dest/"hastyscribe.woff").writeFile(hastyscribe_font)

proc compileFragment*(hs: var HastyScribe, input, dir: string, toc = false): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Process markdown
  var flags = MKD_EXTRA_FOOTNOTE or MKD_NOHEADER or MKD_DLEXTRA or MKD_FENCEDCODE or MKD_GITHUBTAGS or MKD_HTML5ANCHOR
  if toc:
    flags = flags or MKD_TOC
  hs.document = hs.document.md(flags)
  return hs.document

proc compileDocument*(hs: var HastyScribe, input, dir: string): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Document Variables
  var 
    main_css_tag = stylesheet.style_tag
    user_css_tag = ""
    user_js_tag = ""
    watermark_css_tag  = ""
    headings = " class=\"headings\""
    author_footer = ""
    title_tag = ""
    header_tag = ""
    toc = ""
    metadata = TMDMetaData(title:"", author:"", date:"", toc:"", css:"")
  # Process markdown
  hs.document = hs.document.md(0, metadata)
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

  if hs.options.css != "":
    user_css_tag = hs.options.css.readFile.style_tag

  if hs.options.js != "":
    user_js_tag = "<script type=\"text/javascript\">\n" & hs.options.js.readFile & "\n</script>"

  if hs.options.watermark != "":
    watermark_css_tag = watermark_css(hs.options.watermark)

  # Date parsing and validation
  var timeinfo: DateTime = local(getTime())


  try:
    timeinfo = parse(metadata.date, "yyyy-MM-dd")
  except:
    timeinfo = parse(getDateStr(), "yyyy-MM-dd")   

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
  $js
</body>""" % ["title_tag", title_tag, "header_tag", header_tag, "author", metadata.author, "author_footer", author_footer, "date", timeinfo.format("MMMM d, yyyy"), "toc", toc, "main_css_tag", main_css_tag, "user_css_tag", user_css_tag, "headings", headings, "body", hs.document,
"fonts_css_tag", embed_fonts(), "internal_css_tag", metadata.css, "watermark_css_tag", watermark_css_tag, "js", user_js_tag]
  hs.embed_images(dir)
  hs.document = add_jump_to_top_links(hs.document)
  return hs.document

proc compile*(hs: var HastyScribe, input_file: string) =
  let inputsplit = input_file.splitFile
  var input = input_file.readFile
  var output: string

  if hs.options.output == "":
    output = inputsplit.dir/inputsplit.name & ".htm"
  else:
    output = hs.options.output

  if hs.options.fragment:
    hs.compileFragment(input, inputsplit.dir)
  else:
    hs.compileDocument(input, inputsplit.dir)
  if output != "-":
    output.writeFile(hs.document)
  else:
    stdout.write(hs.document)

### MAIN

when isMainModule:
  let usage = "  HastyScribe v" & pkgVersion & " - Self-contained Markdown Compiler" & """

  (c) 2013-2020 Fabio Cevasco

  Usage:
    hastyscribe <markdown_file_or_glob> [options]

  Arguments:
    markdown_file_or_glob   The markdown (or glob expression) file to compile into HTML.
  Options:
    --field/<field>=<value> Define a new field called <field> with value <value>.
    --notoc                 Do not generate a Table of Contents.
    --user-css=<file>       Insert contents of <file> as a CSS stylesheet.
    --user-js=<file>        Insert contents of <file> as a Javascript script.
    --output-file=<file>    Write output to <file>.
                            (Use "--output-file=-" to output to stdout)
    --watermark=<file>      Use the image in <file> as a watermark.
    --fragment              If specified, an HTML fragment will be generated, without 
                            embedding images, fonts, or stylesheets. 
    --dump=all|styles|fonts Dumps all resources/stylesheets/fonts to the current directory.
    --help                  Display the usage information."""
    

  var input = ""
  var files = newSeq[string](0)
  var options = HastyOptions(toc: true, output: "", css: "", watermark: "", fragment: false)
  var fields = initTable[string, string]()
  var dumpdata = ""

  # Parse Parameters

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      input = key
    of cmdLongOption:
      case key
      of "dump":
        if not ["all", "styles", "fonts"].contains(val):
          fatal "[dump] Invalid value: " & val
          quit(7)
        dumpdata = val
      of "notoc":
        options.toc = false
      of "user-css":
        options.css = val
      of "user-js":
        options.js = val
      of "watermark":
        options.watermark = val
      of "output-file":
        options.output = val
      of "fragment":
        options.fragment = true
      of "help":
        echo usage
        quit(1)  
      else:
        if key.startsWith("field/"):
          let val = val
          fields[key.replace("field/", "")] = val          
        discard
    else: 
      discard

  for file in walkFiles(input):
    files.add(file)

  if files.len == 0 and dumpdata == "":
    fatal "\"$1\" does not match any file" % [input]
    quit(2)
  else:
    var hs = newHastyScribe(options, fields)
    if dumpdata != "":
      hs.dump(dumpdata)
      quit(0)
    try:
      for file in files:
        hs.compile(file)
    except IOError:
      let msg = getCurrentExceptionMsg()
      fatal msg
      quit(3)
