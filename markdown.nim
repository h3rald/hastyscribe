##ifndef _MKDIO_D
##define _MKDIO_D

type 
  MMIOT* = int
  mkd_flag_t* = uint32

# line builder for markdown()
# 
{.push importc, cdecl.}
proc mkd_in*(a2: TFile; a3: mkd_flag_t): ptr MMIOT
# assemble input from a file 

proc mkd_string*(a2: cstring; a3: cint; a4: mkd_flag_t): ptr MMIOT
# assemble input from a buffer 
# line builder for github flavoured markdown
# 

proc gfm_in*(a2: TFile; a3: mkd_flag_t): ptr MMIOT
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

proc mkd_dump*(a2: ptr MMIOT; a3: TFile; a4: cint; a5: cstring): cint
proc markdown*(a2: ptr MMIOT; a3: TFile; a4: mkd_flag_t): cint
proc mkd_line*(a2: cstring; a3: cint; a4: cstringArray; a5: mkd_flag_t): cint
type 
  mkd_sta_function_t* = proc (a2: cint; a3: pointer): cint

proc mkd_string_to_anchor*(a2: cstring; a3: cint; a4: mkd_sta_function_t; 
                           a5: pointer; a6: cint)
proc mkd_xhtmlpage*(a2: ptr MMIOT; a3: cint; a4: TFile): cint
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

proc mkd_generatehtml*(a2: ptr MMIOT; a3: TFile): cint
proc mkd_generatetoc*(a2: ptr MMIOT; a3: TFile): cint
proc mkd_generatexml*(a2: cstring; a3: cint; a4: TFile): cint
proc mkd_generatecss*(a2: ptr MMIOT; a3: TFile): cint
const 
  mkd_style* = mkd_generatecss

proc mkd_generateline*(a2: cstring; a3: cint; a4: TFile; a5: mkd_flag_t): cint
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

proc mkd_mmiot_flags*(a2: TFile; a3: ptr MMIOT; a4: cint)
proc mkd_flags_are*(a2: TFile; a3: mkd_flag_t; a4: cint)
proc mkd_ref_prefix*(a2: ptr MMIOT; a3: cstring)
# special flags for markdown() and mkd_text()
# 

{.pop.}

const 
  MKD_NOLINKS* = 0x00000001   # don't do link processing, block <a> tags  
  MKD_NOIMAGE* = 0x00000002   # don't do image processing, block <img> 
  MKD_NOPANTS* = 0x00000004   # don't run smartypants() 
  MKD_NOHTML* = 0x00000008    # don't allow raw html through AT ALL 
  MKD_STRICT* = 0x00000010    # disable SUPERSCRIPT, RELAXED_EMPHASIS 
  MKD_TAGTEXT* = 0x00000020   # process text inside an html tag; no
                              #       <em>, no <bold>, no html or [] expansion 
  MKD_NO_EXT* = 0x00000040    # don't allow pseudo-protocols 
  #MKD_NOEXT* = MKD_NO_EXT     # ^^^ (aliased for user convenience) 
  MKD_CDATA* = 0x00000080     # generate code for xml ![CDATA[...]] 
  MKD_NOSUPERSCRIPT* = 0x00000100 # no A^B 
  MKD_NORELAXED* = 0x00000200 # emphasis happens /everywhere/ 
  MKD_NOTABLES* = 0x00000400  # disallow tables 
  MKD_NOSTRIKETHROUGH* = 0x00000800 # forbid ~~strikethrough~~ 
  MKD_DOTOC* = 0x00001000       # do table-of-contents processing 
  MKD_1_COMPAT* = 0x00002000  # compatibility with MarkdownTest_1.0 
  MKD_AUTOLINK* = 0x00004000  # make http://foo.com link even without <>s 
  MKD_SAFELINK* = 0x00008000  # paranoid check for link protocol 
  MKD_NOHEADER* = 0x00010000  # don't process header blocks 
  MKD_TABSTOP* = 0x00020000   # expand tabs to 4 spaces 
  MKD_NODIVQUOTE* = 0x00040000 # forbid >%class% blocks 
  MKD_NOALPHALIST* = 0x00080000 # forbid alphabetic lists 
  MKD_NODLIST* = 0x00100000   # forbid definition lists 
  MKD_EXTRA_FOOTNOTE* = 0x00200000 # enable markdown extra-style footnotes 
  MKD_NOSTYLE* = 0x00400000   # don't extract <style> blocks 
  MKD_EMBED* = MKD_NOLINKS or MKD_NOIMAGE or MKD_TAGTEXT

# special flags for mkd_in() and mkd_string()

proc md*(s: string, f = 0): string =
  var flags = uint32(f)
  var str = cstring(s)
  var mmiot = mkd_string(str, cint(str.len-1), flags)
  discard mkd_doc_title(mmiot)
  discard mkd_doc_author(mmiot)
  discard mkd_doc_date(mmiot)
  discard mkd_compile(mmiot, flags)
  var res = allocCStringArray([""])
  discard mkd_document(mmiot, res)
  result = cstringArrayToSeq(res)[0]
  mkd_cleanup(mmiot)
  return

