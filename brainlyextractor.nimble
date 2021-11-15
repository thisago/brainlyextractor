# Package

version       = "0.1.3"
author        = "Luciano Lorenzo"
description   = "Brainly data extractor"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.0.0" # Lower this
requires "scraper"

task gen_docs, "Generates the documentation":
  exec "nim doc --project --out:docs src/brainlyextractor.nim"
