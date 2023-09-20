import std/[pegs]
from std/strutils import strip

type
  CssSelPriority* = enum csspIgnore, csspLowProto, csspDom, csspExt, csspProto
  Rule = tuple[selValue: string, definition: string] ## CSS selector rule
  Rules = seq[Rule]

const CssSelLowPriorityProtos = ["http", "https"]

proc parseLinkRules(css: string): array[CssSelPriority, Rules] =
  ## Parses a CSS in format adgering to `hastystyles.links.css`:
  ## Each line is a link styling with a single selector of
  ## `^=` / `*=` / `$=` and a `:before`
  # TODO: - Support multiple selectors for a styling:
  #         either in form of "a[href$='.zip']:before, a[href$='.gz']:before"
  #         or "a:is([href$='.zip'], [href$='.gz']):before"
  #       - Support `:after`
  let peg_linkstyle_def = peg"""
    styles <- definition*
    definition <- 'a[href' op '\'' val '\']:before' \s* @ (\n / $)
    op <- ['^*$'] '='
    val <- [a-z0-9-.#]+
  """
  var attr: tuple[kind: CssSelPriority; selValue: string]
  var linkRules: array[CssSelPriority, Rules]
  let parse = peg_linkstyle_def.eventParser:
    pkNonTerminal:
      leave:
        #debugEcho "leaving ", p.nt.name, " len=", length
        if length > 0:
          case p.nt.name
          of "op":
            # debugEcho "  op:", s.substr(start, start+1)
            attr.kind = case s[start]:
              of '$': csspExt   # endsWiths
              of '*': csspDom   # contains
              of '^': csspProto # startsWith
              else: csspIgnore
          of "val":
            attr.selValue = s.substr(start, start+length-1)
            if attr.kind == csspProto and attr.selValue in CssSelLowPriorityProtos:
              attr.kind = csspLowProto
          of "definition":
            let definition = s.substr(start, start+length-1).strip()
            if attr.kind == csspIgnore or attr.selValue == "" or definition == "":
              echo "Error parsing `stylesheet_links`!"; quit(1)
            linkRules[attr.kind].add((attr.selValue, definition))
            attr = (csspLowProto, "")
          else: discard # parsed the file
  discard parse(css)
  linkRules


const
  stylesheet* = "./data/hastystyles.css".slurp
  stylesheet_badges* = "./data/hastystyles.badges.css".slurp
  stylesheet_icons* = "./data/hastystyles.icons.css".slurp
  #stylesheet_links* = "./data/hastystyles.links.css".slurp
  css_rules_links* = parseLinkRules("./data/hastystyles.links.css".slurp)
  stylesheet_notes* = "./data/hastystyles.notes.css".slurp
  hastyscribe_logo* = "./data/hastyscribe.svg".slurp
  watermark_style* = """
#container {
  position: relative;
  z-index: 0;
}
#container:after {
  content: "";
  opacity: 0.1;
  z-index: -1;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  background-image: url($1);
  background-repeat: no-repeat;
  background-position: center 70px;
  background-attachment: fixed;
}
"""
  eof_separator* = "<!-- $name: EOF -->"
