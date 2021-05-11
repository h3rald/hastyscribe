const 
  MKDIO_D* = true
type 
  MMIOT* = int
  mkd_flag_t* = cuint

{.push importc, cdecl.}
# line builder for markdown()
# 
proc mkd_in*(a2: ptr FILE; a3: mkd_flag_t): ptr MMIOT
# assemble input from a file 
proc mkd_string*(a2: cstring; a3: cint; a4: mkd_flag_t): ptr MMIOT
# assemble input from a buffer 
# line builder for github flavoured markdown
# 
proc gfm_in*(a2: ptr FILE; a3: mkd_flag_t): ptr MMIOT
# assemble input from a file 
proc gfm_string*(a2: cstring; a3: cint; a4: mkd_flag_t): ptr MMIOT
# assemble input from a buffer 
proc mkd_basename*(a2: ptr MMIOT; a3: cstring)
proc mkd_initialize*()
proc mkd_with_html5_tags*()
proc mkd_shlib_destructor*()
# compilation, debugging, cleanup
# 
proc mkd_compile*(a2: ptr MMIOT; a3: mkd_flag_t): cint
proc mkd_cleanup*(a2: ptr MMIOT)
# markup functions
# 
proc mkd_dump*(a2: ptr MMIOT; a3: ptr FILE; a4: cint; a5: cstring): cint
proc markdown*(a2: ptr MMIOT; a3: ptr FILE; a4: mkd_flag_t): cint
proc mkd_line*(a2: cstring; a3: cint; a4: cstringArray; a5: mkd_flag_t): cint
type 
  mkd_sta_function_t* = proc (a2: cint; a3: pointer): cint
proc mkd_string_to_anchor*(a2: cstring; a3: cint; a4: mkd_sta_function_t; 
                           a5: pointer; a6: cint)
proc mkd_xhtmlpage*(a2: ptr MMIOT; a3: cint; a4: ptr FILE): cint
# header block access
# 
proc mkd_doc_title*(a2: ptr MMIOT): cstring
proc mkd_doc_author*(a2: ptr MMIOT): cstring
proc mkd_doc_date*(a2: ptr MMIOT): cstring
# compiled data access
# 
proc mkd_document*(a2: ptr MMIOT; a3: cstringArray): cint
proc mkd_toc*(a2: ptr MMIOT; a3: cstringArray): cint
proc mkd_css*(a2: ptr MMIOT; a3: cstringArray): cint
proc mkd_xml*(a2: cstring; a3: cint; a4: cstringArray): cint
# write-to-file functions
# 
proc mkd_generatehtml*(a2: ptr MMIOT; a3: ptr FILE): cint
proc mkd_generatetoc*(a2: ptr MMIOT; a3: ptr FILE): cint
proc mkd_generatexml*(a2: cstring; a3: cint; a4: ptr FILE): cint
proc mkd_generatecss*(a2: ptr MMIOT; a3: ptr FILE): cint
const 
  mkd_style* = mkd_generatecss
proc mkd_generateline*(a2: cstring; a3: cint; a4: ptr FILE; a5: mkd_flag_t): cint
const 
  mkd_text* = mkd_generateline
# url generator callbacks
# 
type 
  mkd_callback_t* = proc (a2: cstring; a3: cint; a4: pointer): cstring
  mkd_free_t* = proc (a2: cstring; a3: pointer)
proc mkd_e_url*(a2: pointer; a3: mkd_callback_t)
proc mkd_e_flags*(a2: pointer; a3: mkd_callback_t)
proc mkd_e_free*(a2: pointer; a3: mkd_free_t)
proc mkd_e_data*(a2: pointer; a3: pointer)
# version#.
# 
var markdown_version*: ptr char
proc mkd_mmiot_flags*(a2: ptr FILE; a3: ptr MMIOT; a4: cint)
proc mkd_flags_are*(a2: ptr FILE; a3: mkd_flag_t; a4: cint)
proc mkd_ref_prefix*(a2: ptr MMIOT; a3: cstring)
{.pop.}

# special flags for markdown() and mkd_text()
# 
const 
  MKD_NOLINKS* = 0x00000001
  MKD_NOIMAGE* = 0x00000002
  MKD_NOPANTS* = 0x00000004
  MKD_NOHTML* = 0x00000008
  MKD_STRICT* = 0x00000010
  MKD_TAGTEXT* = 0x00000020
  MKD_NO_EXT* = 0x00000040
  MKD_CDATA* = 0x00000080
  MKD_NOSUPERSCRIPT* = 0x00000100
  MKD_NORELAXED* = 0x00000200
  MKD_NOTABLES* = 0x00000400
  MKD_NOSTRIKETHROUGH* = 0x00000800
  MKD_TOC* = 0x00001000
  MKD_1_COMPAT* = 0x00002000
  MKD_AUTOLINK* = 0x00004000
  MKD_SAFELINK* = 0x00008000
  MKD_NOHEADER* = 0x00010000
  MKD_TABSTOP* = 0x00020000
  MKD_NODIVQUOTE* = 0x00040000
  MKD_NOALPHALIST* = 0x00080000
  MKD_NODLIST* = 0x00100000
  MKD_EXTRA_FOOTNOTE* = 0x00200000
  MKD_NOSTYLE* = 0x00400000
  MKD_NODLDISCOUNT* = 0x00800000
  MKD_DLEXTRA* = 0x01000000
  MKD_FENCEDCODE* = 0x02000000
  MKD_IDANCHOR* = 0x04000000
  MKD_GITHUBTAGS* = 0x08000000
  MKD_URLENCODEDANCHOR* = 0x10000000
  MKD_HTML5ANCHOR* = 0x10000000
  MKD_LATEX* = 0x40000000
  MKD_EMBED* = MKD_NOLINKS or MKD_NOIMAGE or MKD_TAGTEXT

## High Level API

import 
  strutils,
  pegs

const 
  DefaultFlags = MKD_TOC or MKD_1_COMPAT or MKD_EXTRA_FOOTNOTE or MKD_DLEXTRA or MKD_FENCEDCODE or MKD_GITHUBTAGS or MKD_HTML5ANCHOR or MKD_LATEX

type TMDMetaData* = object 
  title*: string
  author*: string
  date*: string
  toc*: string
  css*: string

proc md*(s: string, f = 0): string =
  var flags: uint32
  if (f == 0):
    flags = DefaultFlags
  else: 
    flags = uint32(f)
  var str = cstring(s&" ")
  var mmiot = mkd_string(str, cint(str.len-1), flags)
  discard mkd_compile(mmiot, flags)
  var res = allocCStringArray([""])
  discard mkd_document(mmiot, res)
  result = cstringArrayToSeq(res)[0]
  mkd_cleanup(mmiot)
  return

proc md*(s: string, f = 0, data: var TMDMetadata): string =
  var flags: uint32
  if (f == 0):
    flags = DefaultFlags
  else: 
    flags = uint32(f)
  # Check if Pandoc style metadata is present
  var valid_metadata = false
  var contents = s
  let peg_pandoc = peg"""
    definition <- ^{line} {line}? {line}?
    line <- '\%' @ \n
  """
  var matches: array[0..2, string] 
  let (s, e) = contents.findBounds(peg_pandoc, matches)
  # the pattern must start at the beginning of the file
  if s == 0:
    if matches[0] != "" and matches[1] != "" and matches[2] != "":
      valid_metadata = true
    else:
      # incomplete metadata, remove the whole pandoc section to not confuse discount
      contents = contents[e-1 .. ^1]  
  var str = cstring(contents)
  var mmiot = mkd_string(str, cint(str.len), flags)
  if valid_metadata:
    data.title = $mkd_doc_title(mmiot)
    data.author = $mkd_doc_author(mmiot)
    data.date = $mkd_doc_date(mmiot)
  discard mkd_compile(mmiot, flags)
  # Process TOC
  if (int(flags) and MKD_TOC) == MKD_TOC:
    var toc = allocCStringArray(@[""])
    if mkd_toc(mmiot, toc) > 0:
      data.toc = cstringArrayToSeq(toc)[0]
    else:
      data.toc = ""
  # Process CSS
  var css = allocCStringArray(newSeq[string](10))
  if mkd_css(mmiot, css) > 0:
    data.css = cstringArrayToSeq(css)[0]
  else:
    data.css = ""
  # Generate HTML
  var res = allocCStringArray([""])
  if mkd_document(mmiot, res) > 0:
    result = cstringArrayToSeq(res)[0]
  else:
    result = ""
  mkd_cleanup(mmiot)
