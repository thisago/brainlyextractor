# Package

version       = "0.1.0"
author        = "Luciano Lorenzo"
description   = "Brainly data extractor"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.5.1" # Lower this
requires "https://github.com/letil/chttpclient" # Waiting pull be accepted
requires "findxml"

task gen_docs, "Generates the documentation":
  exec "nim doc --project --out:docs src/brainlyextractor.nim"
