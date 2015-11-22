[Package]
name          = "hastyscribe"
version       = "1.1.4"
author        = "Fabio Cevasco"
description   = "Self-contained markdown compiler generating self-contained HTML documents"
license       = "MIT"

bin = "hastyscribe"

InstallFiles = """
assets/fonts/fontawesome-webfont.woff
assets/fonts/hastyscribe.woff
assets/fonts/SourceCodePro-Regular.ttf.woff
assets/fonts/SourceSansPro-Bold.ttf.woff
assets/fonts/SourceSansPro-BoldIt.ttf.woff
assets/fonts/SourceSansPro-It.ttf.woff
assets/fonts/SourceSansPro-Regular.ttf.woff
assets/images/hastyscribe.png
assets/images/hastyscribe.svg
assets/styles/hastyscribe.css
assets/styles/hastyscribe.less
assets/styles/_badges.less
assets/styles/_blocks.less
assets/styles/_elements.less
assets/styles/_fa-icons.less
assets/styles/_fa-variables.less
assets/styles/_headings.less
assets/styles/_links.less
assets/styles/_mixins.less
assets/styles/_normalize.less
assets/styles/_printing.less
assets/styles/_variables.less
doc/HastyScribe_UserGuide.htm
doc/HastyScribe_UserGuide.md
hastyscribe.nim
LICENSE.md
markdown.nim
README.md
vendor/libmarkdown_macosx_x64.a
vendor/libmarkdown_windows_x64.a
vendor/libmarkdown_windows_x86.a
vendor/libmarkdown_linux_x86.a
vendor/libmarkdown_linux_arm.a
"""

[Deps]
Requires: "nimrod >= 0.12.0"
