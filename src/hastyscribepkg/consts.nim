
const
  stylesheet* = "./data/hastystyles.css".slurp
  stylesheet_badges* = "./data/hastystyles.badges.css".slurp
  stylesheet_icons* = "./data/hastystyles.icons.css".slurp
  stylesheet_links* = "./data/hastystyles.links.css".slurp
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
