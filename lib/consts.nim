
const 
  stylesheet* = "../packages/hastystyles/styles/hastyscribe.css".slurp
  hastyscribe_font* = "../packages/hastystyles/fonts/hastyscribe.woff".slurp 
  fontawesome_font* = "../packages/hastystyles/fonts/fontawesome-webfont.woff".slurp
  sourcecodepro_font* = "../packages/hastystyles/fonts/SourceCodePro-Regular.ttf.woff".slurp
  sourcesanspro_font* = "../packages/hastystyles/fonts/SourceSansPro-Regular.ttf.woff".slurp
  sourcesanspro_bold_font* = "../packages/hastystyles/fonts/SourceSansPro-Bold.ttf.woff".slurp
  sourcesanspro_it_font* = "../packages/hastystyles/fonts/SourceSansPro-It.ttf.woff".slurp
  sourcesanspro_boldit_font* = "../packages/hastystyles/fonts/SourceSansPro-BoldIt.ttf.woff".slurp
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
