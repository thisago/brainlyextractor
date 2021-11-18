import std/[
  unittest,
  asyncdispatch
]
import brainlyextractor

const urls = ["https://brainly.com/question/18649296", "https://brainly.com/question/24600056", "https://brainly.com.br/tarefa/36901808", "https://brainly.lat/tarea/56119687", "https://brainly.ro/tema/7413901", "https://brainly.com.br/tarefa/48483897", ]

suite "Not breaking":
  for url in urls:
    test url:
      try:
        discard waitFor getQuestion url
      except:
        echo getCurrentExceptionMsg()
        check false
      check true
