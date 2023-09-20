import std/[
    macros,
    os,
    parseopt,
    strutils,
    times,
    pegs,
    xmltree,
    tables,
    httpclient,
    logging,
    critbits,
    sets,
  ]

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
    toc*: bool = true
    input*: string = ""
    output*: string = ""
    css*: string = ""
    js*: string = ""
    watermark*: string
    fragment*: bool = false
    embed*: bool = true
    iso*: bool = false
    noclobber*: bool = false
    outputToDir*: bool = false
    processingMultiple: bool = false
  HastyFields* = Table[string, string]
  HastySnippets* = Table[string, string]
  HastyMacros* = Table[string, string]
  HastyIconStyles* = Table[string, string]
  HastyNoteStyles* = Table[string, string]
  HastyBadgeStyles* = Table[string, string]
  HastyScribe* = object
    options: HastyOptions
    fields: HastyFields
    snippets: HastySnippets
    macros: HastyMacros
    document: string
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
      except CatchableError as e:
        warn "Unable to download '$1'\n    Reason: $2\n" % [imgfile, e.msg] &
             "     -> Image will be linked instead"
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
  # Links -> already in `consts.css_rules_links`

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

proc remove_escapes(hs: var HastyScribe, document: string): string =
  ## Substitute escaped brackets or hashes *after* preprocessing
  document.replacef(peg"'\\' {'{' / '}' / '#'}", "$1")

proc parse_anchors(hs: var HastyScribe, document: string): string =
  let peg_anchor = peg"""
    anchor <- \s '#' {id} '#'
    id <- [a-zA-Z][a-zA-Z0-9:._-]+
  """
  document.replacef(peg_anchor, """ <a id="$1"></a>""")

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
  ## Analyzes the provided HTML document for using elements matching
  ## the set of "hastystyles" CSS rules and prepares a custom CSS with the
  ## used resources.
  let html = document.parseHtml()
  var rules: seq[string]

  block icons_badges_notes:
    var selSet: HashSet[string]
    template fillFrom(rules: var seq[string]; t: Table[string, string]; selector, obj: string) =
      for el in html.querySelectorAll(selector): selSet.incl(el.attr("class"))
      for selV in selSet.items: rules.add(getTableValue(t, selV, obj))
      selSet.init()
    rules.fillFrom(hs.iconStyles, "span[class^=fa-]", "Icon") # Check icons
    rules.fillFrom(hs.badgeStyles, "span[class^=badge-]", "Badge") # Check badges
    rules.fillFrom(hs.noteStyles, "div.tip, div.warning, div.note, div.sidebar", "Note") # Check notes

  block linkStyles: # Check links
    # Init with `document-top`: it's added to the document later with `utils.add_jump_to_top_links`
    var linkHrefs: CritBitTree[void] = ["#document-top"].toCritBitTree()
    for link in html.querySelectorAll("a[href]"): linkHrefs.incl(link.attr("href"))
    var linkRulesSet: tuple[exts, doms, protos: CritBitTree[void]]
    for href in linkHrefs.keys:
      block search:
        for (val, rule) in css_rules_links.extensions:
          if href.endsWith(val): linkRulesSet.exts.incl(rule); break search
        for (val, rule) in css_rules_links.domains:
          if href.contains(val): linkRulesSet.doms.incl(rule); break search
        for (val, rule) in css_rules_links.protocols:
          if href.startsWith(val): linkRulesSet.protos.incl(rule); break search
    # Adding to rules in reversed order of precedence
    for rule in linkRulesSet.protos.keys: rules.add(rule)
    for rule in linkRulesSet.doms.keys: rules.add(rule)
    for rule in linkRulesSet.exts.keys: rules.add(rule)

  rules.join("\n").style_tag()


# Public API

proc compileFragment*(hs: var HastyScribe, input, dir: string, toc = false): string {.discardable.} =
  hs.document = input
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Process markdown
  var flags = MKD_EXTRA_FOOTNOTE or MKD_NOHEADER or MKD_DLEXTRA or MKD_FENCEDCODE or MKD_GITHUBTAGS or MKD_URLENCODEDANCHOR
  if toc:
    flags = flags or MKD_TOC
  hs.document = hs.document.md(flags)
  return hs.document

proc compileDocument*(hs: var HastyScribe, input, dir: string): string {.discardable.} =
  hs.document = input
  # Load style rules to be included on-demand
  hs.load_styles()
  # Parse transclusions, fields, snippets, and macros
  hs.document = hs.preprocess(hs.document, dir)
  # Process markdown
  var metadata: TMDMetaData
  hs.document = hs.document.md(0, metadata)

  # Document Variables
  const hastyscribe_img = """
<img src="$#" width="80" height="23" alt="HastyScribe">
""" % encode_image(hastyscribe_logo, "svg")
  let
    (headings, toc) = if hs.options.toc and metadata.toc != "":
        (" class=\"headings\"", "<div id=\"toc\">" & metadata.toc & "</div>")
      else: ("", "")
    user_css_tag = if hs.options.css == "": "" else:
        hs.options.css.readFile.style_tag
    user_js_tag = if hs.options.js == "": "" else:
      "<script type=\"text/javascript\">\n" & hs.options.js.readFile & "\n</script>"
    watermark_css_tag = if hs.options.watermark == "": "" else:
      watermark_css(hs.options.watermark)

    # Manage metadata
    author_footer = if metadata.author == "": "" else:
      "<span class=\"copy\"></span> " & metadata.author & " &ndash;"
    title_tag = if metadata.title == "": "" else:
      "<title>" & metadata.title & "</title>"
    header_tag = if metadata.title == "": "" else:
      "<div id=\"header\"><h1>" & metadata.title & "</h1></div>"

    (main_css_tag, optional_css_tag) = if hs.options.embed:
        (stylesheet.style_tag, hs.create_optional_css(hs.document))
      else:
        ("", "")

  # Date parsing and validation
  let date: string = block:
    const IsoDate = initTimeFormat("yyyy-MM-dd")
    const DefaultDate = initTimeFormat("MMMM d, yyyy")
    let timeinfo: DateTime = try:
        parse(metadata.date, IsoDate)
      except CatchableError:
        local(getTime())
    timeinfo.format(if hs.options.iso: IsoDate else: DefaultDate)

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
      <p><span>Powered by</span> <a href="https://h3rald.com/hastyscribe" class="hastyscribe-logo">$hastyscribe_img</a></p>
    </div>
  </div>
  $js
</body>""" % [
    "title_tag", title_tag,
    "header_tag", header_tag,
    "author", metadata.author,
    "author_footer", author_footer,
    "date", date,
    "toc", toc,
    "main_css_tag", main_css_tag,
    "hastyscribe_img", hastyscribe_img,
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

type ClobberError = object of CatchableError

proc compile(hs: var HastyScribe; input_file, out_basename: string)
     {.raises: [IOError, ref ValueError, OSError, Exception, ClobberError].} =
  const OutputExt = ".htm"
  let
    (dir, name, _) = input_file.splitFile()
    input: string = input_file.readFile()
    outBaseName = if out_basename != "": out_basename else: name
    outputPath: string = if hs.options.output == "":
        dir/outBaseName & OutputExt
      else:
        if hs.options.outputToDir: # explicit name is a dir
          hs.options.output / outBaseName & OutputExt
        else: # explicit name is a file path
          hs.options.output

  if hs.options.fragment:
    hs.compileFragment(input, dir)
  else:
    hs.compileDocument(input, dir)
  if outputPath == "-":
    stdout.write(hs.document)
    if hs.options.processingMultiple:
      stdout.write("\n" & (eof_separator % ["name", name]) & "\n")
  else:
    if fileExists(outputPath) and hs.options.noclobber:
      raise newException(ClobberError, outputPath)
    else:
      # TODO: implement atomic writes with temp files
      outputPath.writeFile(hs.document)

proc compile*(hs: var HastyScribe, input_file: string)
     {.raises: [IOError, ref ValueError, OSError, Exception, ClobberError].} =
  compile(hs, input_file, "")

proc fileNameMappings(paths: sink CritBitTree[void]): seq[tuple[path, name: string]] =
  ## This function preemptively deals with potential name collisions on
  ## writing multiple files to a flat output directory
  ## Outputs a mapping of file paths to their unique base names
  var baseNameSet: CritBitTree[(int, bool)] # (indexInMap, madeUnique)
  var i = 0
  for path in paths:
    let (dir, name, _) = path.splitFile()
    if baseNameSet.containsOrIncl(name, (i, false)):
      let (oldIdx, madeUnique) = baseNameSet[name]
      if not madeUnique: # First collision, make both old and new files unique
        let oldMap = result[oldIdx]
        let newName = makeFNameUnique(oldMap.name, oldMap.path.splitFile.dir)
        result[oldIdx] = (path: oldMap.path, name: newName)
        baseNameSet[name] = (oldIdx, true)
      # Subsequent name collisions, make only the new name unique
      result.add (path: path, name: makeFNameUnique(name, dir))
    else:
      baseNameSet.incl(name, (i, false))
      result.add (path: path, name: name)
    i.inc()

### MAIN
when isMainModule:
  const usage = "  HastyScribe v" & pkgVersion & " - Self-contained Markdown Compiler" & """

  (c) 2013-2023 Fabio Cevasco

  Usage:
    hastyscribe [options] <markdown_file_or_glob> ...

  Arguments:
    markdown_file_or_glob   The markdown (or glob expression) file to compile into HTML.
  Options:
    --output-file=<file>    Write output to <file>.
                            (Use "--output-file=-" to output to stdout)
    --output-dir=<dir>, -d=<dir> Write output files to <dir>. Overrides "output-file".
                                 Input directory structure is not preserved.
    --field/<field>=<value> Define a new field called <field> with value <value>.
    --user-css=<file>       Insert contents of <file> as a CSS stylesheet.
    --user-js=<file>        Insert contents of <file> as a Javascript script.
    --watermark=<file>      Use the image in <file> as a watermark.
    --notoc                 Do not generate a Table of Contents.
    --noembed               If specified, styles and images will not be embedded.
    --fragment              If specified, an HTML fragment will be generated, without
                            embedding images or stylesheets.
    --iso                   Use ISO 8601 date format (e.g., 2000-12-31) in the footer.
    --no-clobber, -n        Do not overwrite existing files.
    --help,       -h        Display the usage information.
    --version,    -v        Print version and exit."""

  type ErrorKinds = enum errENOENT = 2, errEIO = 5

  var
    inputs: seq[string]
    options = default(HastyOptions)
    fields = initTable[string, string]()

  # Parse Parameters
  template noVal() =
    if val != "": fatal "Option '" & key & "' takes no value"; quit(1)
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
        inputs.add(key)
    of cmdShortOption, cmdLongOption:
      case key
      of "notoc":
        noVal()
        options.toc = false
      of "noembed":
        noVal()
        options.embed = false
      of "user-css":
        options.css = val
      of "user-js":
        options.js = val
      of "watermark":
        options.watermark = val
      of "output-file":
        if not options.outputToDir:
          if val == "": fatal "Output file path can't be empty"; quit(1)
          options.output = val
      of "d", "output-dir":
        options.outputToDir = true
        if dirExists(val): options.output = val.normalizedPath()
        else:
          fatal "Directory '" & val & "' does not exist";
          quit(errENOENT.ord)
      of "fragment":
        noVal()
        options.fragment = true
      of "iso":
        noVal()
        options.iso = true
      of "n", "no-clobber", "noclobber":
        noVal()
        options.noclobber = true
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
        else:
          warn """Unknown option "$#", ignoring""" % key
    of cmdEnd: assert(false)
  if inputs.len == 0:
    echo usage
    quit(0)
  else:
    var errorsOccurred: set[ErrorKinds] = {}
    var paths: CritBitTree[void] # Deduplicates different globs expanding to same files
    for glob in inputs:
      var globMatchCount = 0
      for file in walkFiles(glob):
        # TODO: files can still contain relative and absolute paths pointing to the same file
        let path = file.normalizedPath()
        if paths.containsOrIncl(path):
          notice "Input file \"$1\" provided multiple times" % path
        globMatchCount.inc()
      if globMatchCount == 0:
        errorsOccurred.incl errENOENT
        fatal "\"$1\" does not match any file" % glob
    if paths.len == 0:
      errorsOccurred.incl errENOENT
    else:
      var fileMappings: seq[tuple[path, name: string]]
      if paths.len > 1:
        options.processingMultiple = true
        if not options.outputToDir:
          case options.output:
            of "": discard
            of "-":
              notice "Multiple files will be printed to stdout using the\n" &
                   "    \"" & eof_Separator & "\" separator."
            else:
              warn "Option `output-file` is set but multiple input files given, ignoring"
              options.output = ""
        fileMappings = fileNameMappings(paths)
      else:
        for p in paths.keys:
          fileMappings.add (path: p, name: "")

      var hs = newHastyScribe(options, fields)
      for (path, outName) in fileMappings:
        try:
          hs.compile(path, outName)
        except IOError as e:
          errorsOccurred.incl errEIO
          fatal e.msg
          continue
        except ClobberError as e:
          warn "File '" & e.msg & "' exists, not overwriting"
          continue
        info "\"$1\" converted successfully" % path
    if errENOENT in errorsOccurred: quit(errENOENT.ord)
    elif errEIO in errorsOccurred: quit(errEIO.ord)
    else: discard # ok
