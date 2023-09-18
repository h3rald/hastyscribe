import std/[pegs]
from std/strutils import strip

type
  Rule = tuple[selValue: string, definition: string]
  Rules = seq[Rule]

proc parseLinkRules(css: string): tuple[extensions, domains, protocols: Rules] =
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
  type
    CssSelectorKind = enum
      selUnknown = "", selEnds = "$=", selContains = "*=", selStarts = "^="
    RuleAttrs = object
      kind: CssSelectorKind = selUnknown
      selValue: string = ""
  var extensions, domains, protocols: Rules
  var attrs = default(RuleAttrs)
  let parse = peg_linkstyle_def.eventParser:
    pkNonTerminal:
      leave:
        #debugEcho "leaving ", p.nt.name, " len=", length
        if length > 0:
          case p.nt.name
          of "op":
            # debugEcho "  op:", s.substr(start, start+1)
            attrs.kind = case s[start]:
              of '$': selEnds
              of '*': selContains
              of '^': selStarts
              else: selUnknown
          of "val": attrs.selValue = s.substr(start, start+length-1)
          of "definition":
            let definition = s.substr(start, start+length-1).strip()
            if attrs.kind == selUnknown or attrs.selValue == "" or definition == "":
              echo "Error parsing `stylesheet_links`!"; quit(1)
            case attrs.kind:
              of selEnds: extensions.add((attrs.selValue, definition))
              of selContains: domains.add((attrs.selValue, definition))
              of selStarts: protocols.add((attrs.selValue, definition))
              else: doAssert(false) # already checked
            attrs = default(RuleAttrs)
          else: discard # parsed the file
  discard parse(css)
  (extensions: extensions, domains: domains, protocols: protocols)


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
