import 
  std/macros,
  std/os, 
  std/parseopt, 
  std/strutils,
  std/sequtils,
  std/times, 
  std/pegs, 
  std/xmltree,
  std/tables,
  std/httpclient,
  std/logging

from nimquery import querySelectorAll
from std/htmlparser import parseHtml

import
  hastyscribepkg/niftylogger,
  hastyscribepkg/markdown, 
  hastyscribepkg/config,
  hastyscribepkg/consts,
  hastyscribepkg/utils

export
  consts

when defined(windows) and defined(amd64): 
  {.passL: "-static -L"&getProjectPath()&"/hastyscribepkg/vendor/markdown/windows -lmarkdown".}
elif defined(linux) and defined(amd64):
  {.passL: "-static -L"&getProjectPath()&"/hastyscribepkg/vendor/markdown/linux -lmarkdown".}
elif defined(macosx) and defined(amd64):
  {.passL: "-Bstatic -L"&getProjectPath()&"/hastyscribepkg/vendor/markdown/macosx -lmarkdown -Bdynamic".}


type
  HastyOptions* = object
    toc*: bool
    input*: string
    output*: string
    css*: string
    js*: string
    watermark*: string
    fragment*: bool
    embed*: bool
  HastyFields* = Table[string, string]
  HastySnippets* = Table[string, string]
  HastyMacros* = Table[string, string]
  HastyLinkStyles* = Table[string, string]
  HastyIconStyles* = Table[string, string]
  HastyNoteStyles* = Table[string, string]
  HastyBadgeStyles* = Table[string, string]
  HastyScribe* = object
    options: HastyOptions
    fields: HastyFields
    snippets: HastySnippets
    macros: HastyMacros
    document: string
    linkStyles: HastyLinkStyles
    iconStyles: HastyIconStyles
    noteStyles: HastyNoteStyles
    badgeStyles: HastyBadgeStyles

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
      except CatchableError:
        warn "Unable to download '" & imgfile & "'"
        warn "  Reason: " & getCurrentExceptionMsg()
        warn "  -> Image will be linked instead"
        continue
    else:
      imgcontent = encode_image_file(current_dir & imgfile, imgformat)
    let imgrep = img.replace("\"" & img_file & "\"", "\"" & imgcontent & "\"")
    doc = doc.replace(img, imgrep)
  hs.document = doc

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
      except CatchableError:
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
      except CatchableError:
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

proc load_styles(hs: var HastyScribe) =
  type
    StyleRuleMatches = array[0..1, string]
  # Icons
  let peg_iconstyle_def = peg"""
    definition <- { '.' {icon} ':before' \s* '{'  @ (\n / $) }
    icon <- 'fa-' [a-z0-9-]+
  """
  for def in stylesheet_icons.findAll(peg_iconstyle_def):
    var matches: StyleRuleMatches
    discard def.match(peg_iconstyle_def, matches)
    hs.iconStyles[matches[1].strip] = matches[0].strip
  # Badges
  let peg_badgestyle_def = peg"""
    definition <- { '.' {badge} ':before' \s* '{'  @ (\n / $) }
    badge <- 'badge-' [a-z0-9-]+
  """
  for def in stylesheet_badges.findAll(peg_badgestyle_def):
    var matches: StyleRuleMatches
    discard def.match(peg_badgestyle_def, matches)
    hs.badgeStyles[matches[1].strip] = matches[0].strip
  # Notes
  let peg_notestyle_def = peg"""
    definition <- { '.' {note} \s* '> p:first-child:before {' \s* @ (\n / $) }
    note <- [a-z]+
  """
  for def in stylesheet_notes.findAll(peg_notestyle_def):
    var matches: StyleRuleMatches
    discard def.match(peg_notestyle_def, matches)
    hs.noteStyles[matches[1].strip] = matches[0].strip
  # Links
  let peg_linkstyle_def = peg"""
    definition <- { 'a[href' { ('^=' / '*=' / '$=') '\'' link } '\']:before' \s* @ (\n / $) }
    link <- [a-z0-9-.#]+
  """
  for def in stylesheet_links.findAll(peg_linkstyle_def):
    var matches: StyleRuleMatches
    discard def.match(peg_linkstyle_def, matches)
    hs.linkStyles[matches[1].strip] = matches[0].strip

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

proc getTableValue(table: Table[string, string], key: string, obj: string): string =
  try:
    return table[key]
  except CatchableError:
    warn obj & " not found: " & key

proc create_optional_css*(hs: HastyScribe, document: string): string =
  result = ""
  let html = document.parseHtml
  # Check icons
  let iconRules = html.querySelectorAll("span[class^=fa-]")
    .mapIt(it.attr("class"))
    .mapIt(getTableValue(hs.iconStyles, it, "Icon"))
  result &= iconRules.join("\n")
  # Check badges
  let badgeRules = html.querySelectorAll("span[class^=badge-]")
    .mapIt(it.attr("class"))
    .mapIt(getTableValue(hs.badgeStyles, it, "Badge"))
  result &= badgeRules.join("\n")
  # Check notes
  let noteRules = html.querySelectorAll("div.tip, div.warning, div.note, div.sidebar")
    .mapIt(it.attr("class"))
    .mapIt(getTableValue(hs.noteStyles, it, "Note"))
  result &= noteRules.join("\n")
  # Check links
  let linkHrefs = html.querySelectorAll("a[href]")
    .mapIt(it.attr("href"))
  var linkRules = newSeq[string]()
  # Add #document-top rule because it is always needed and added at the end.
  linkRules.add hs.linkStyles["^='#document-top"]
  for href in linkHrefs:
    for key in hs.linkStyles.keys.toSeq:
      if not linkRules.contains(hs.linkStyles[key]):
        let op = key[0..1]
        let value = key[3..^1] # Skip first '
        var matches = newSeq[string]() # Save matches in order of priority
        if op == "$=" and href.endsWith(value):
          matches.add key
        if op == "*=" and href.contains(value):
          matches.add key
        if op == "^=" and href.startsWith(value):
          matches.add key
        # Add last match
        if matches.len > 0:
          linkRules.add hs.linkStyles[matches[^1]]
          break
  result &= linkRules.join("\n")
  result = result.style_tag

# Public API

proc compileFragment*(hs: var HastyScribe, input, dir: string, toc = false): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Process markdown
  var flags = MKD_EXTRA_FOOTNOTE or MKD_NOHEADER or MKD_DLEXTRA or MKD_FENCEDCODE or MKD_GITHUBTAGS or MKD_URLENCODEDANCHOR
  if toc:
    flags = flags or MKD_TOC
  hs.document = hs.document.md(flags)
  return hs.document

proc compileDocument*(hs: var HastyScribe, input, dir: string): string {.discardable.} =
  hs.options.input = input
  hs.document = hs.options.input
  # Load style rules to be included on-demand
  hs.load_styles()
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Document Variables
  var 
    main_css_tag = ""
    optional_css_tag = ""
    user_css_tag = ""
    user_js_tag = ""
    watermark_css_tag  = ""
    headings = " class=\"headings\""
    author_footer = ""
    title_tag = ""
    header_tag = ""
    toc = ""
    metadata = TMDMetaData(title:"", author:"", date:"", toc:"", css:"")
  let logo_datauri = encode_image(hastyscribe_logo, "svg")
  let hastyscribe_svg = """
  <img src="$#" width="80" height="23" alt="HastyScribe">
  """ % [logo_datauri]
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
  except CatchableError:
    timeinfo = parse(getDateStr(), "yyyy-MM-dd")   
  
  if hs.options.embed:
    main_css_tag = stylesheet.style_tag
    optional_css_tag = hs.create_optional_css(hs.document)

  hs.document = """<!doctype html>
<html lang="en">
<head>
  $title_tag
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="$author">
  <meta name="generator" content="HastyScribe">
  $main_css_tag
  $optional_css_tag
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
      <p><span>Powered by</span> <a href="https://h3rald.com/hastyscribe" class="hastyscribe-logo">$hastyscribe_svg</a></p>
    </div>
  </div>
  $js
</body>""" % [
  "title_tag", title_tag, 
  "header_tag", header_tag, 
  "author", metadata.author, 
  "author_footer", author_footer, 
  "date", timeinfo.format("MMMM d, yyyy"), 
  "toc", toc, 
  "main_css_tag", main_css_tag, 
  "hastyscribe_svg", hastyscribe_svg,
  "optional_css_tag", optional_css_tag, 
  "user_css_tag", user_css_tag, 
  "headings", headings, 
  "body", hs.document, 
  "internal_css_tag", metadata.css, 
  "watermark_css_tag", watermark_css_tag, 
  "js", user_js_tag]
  if hs.options.embed:
    hs.embed_images(dir)
  hs.document = add_jump_to_top_links(hs.document)
  # Use IDs instead of names for anchors
  hs.document = hs.document.replace("<a name=", "<a id=")
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

  (c) 2013-2023 Fabio Cevasco

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
    --noembed               If specified, styles and images will not be embedded.
    --fragment              If specified, an HTML fragment will be generated, without 
                            embedding images ir stylesheets. 
    --help                  Display the usage information."""
    

  var input = ""
  var files = newSeq[string](0)
  var options = HastyOptions(toc: true, output: "", css: "", watermark: "", fragment: false, embed: true)
  var fields = initTable[string, string]()

  # Parse Parameters

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      input = key
    of cmdShortOption, cmdLongOption:
      case key
      of "notoc":
        options.toc = false
      of "noembed":
        options.embed = false
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
      of "v", "version":
        echo pkgVersion
        quit(0)
      of "h", "help":
        echo usage
        quit(0)  
      else:
        if key.startsWith("field/"):
          let val = val
          fields[key.replace("field/", "")] = val          
        discard
    else: 
      discard
  for file in walkFiles(input):
    files.add(file)

  if files.len == 0:
    if input == "":
      echo usage
      quit(0)
    fatal "\"$1\" does not match any file" % [input]
    quit(2)
  else:
    var hs = newHastyScribe(options, fields)
    try:
      for file in files:
        hs.compile(file)
    except IOError:
      let msg = getCurrentExceptionMsg()
      fatal msg
      quit(3)
