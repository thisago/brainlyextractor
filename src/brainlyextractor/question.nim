## Extractor to `/question/` page

from std/httpclient import newAsyncHttpClient, getContent, close, newHttpHeaders
import std/asyncdispatch
from std/strutils import parseInt
from std/xmltree import XmlNode, kind, xnElement

from pkg/scraper/html import findAll, text, attr, parseHtml
from pkg/useragent import mozilla

type
  Question* = object
    url*: string
    title*, body*: string
    author*, avatar*: string
    creation*: int64 ## Unix time
    subject*, grade*: string
    attachments*: seq[string]
    comments*: seq[Comment]
    answers*: seq[Answer]
  Comment* = object
    author*, avatar*: string
    body*: string
  Answer* = object
    author*, avatar*: string
    body*: string
    attachments*: seq[string]
    comments*: seq[Comment]

func extractComment(node: XmlNode): Comment =
  result.body = node.findAll("div", {"class": "sg-text sg-text--small sg-text--break-words"}).text
  let img = node.findAll("img", {"class": "sg-avatar__image"})
  result.author = img.attr "title"
  result.avatar = img.attr "src"

func extractAnswer(node: XmlNode): Answer =
  let data = node.findAll("div", @{"class": "brn-qpage-next-answer-box-author"})[0]
  result.avatar = data.findAll("img", {"class": "sg-avatar__image"}).attr "src"
  result.author = data.findAll("span", {"class": "sg-hide-for-small-only sg-text--small sg-text sg-text--link sg-text--bold sg-text--black"}).text
  block resp:
    let el = node.findAll("div", {"class": "sg-text sg-text--break-words brn-rich-content js-answer-content"})[0].
               findAll "p"
    for p in el:
      if p.kind != xnElement: continue
      if result.body.len > 0:
        result.body.add "\l"
      result.body.add p.text
  block attachements:
    for attachement in node.findAll("div", {"class":"brn-qpage-next-attachments-viewer-image-preview"}):
      let img = attachement.findAll("img").attr "src"
      if img.len > 0:
        result.attachments.add img
        continue
  block comments:
    for comment in node.findAll("li", {"class": "brn-qpage-next-comments__list-item"}):
      result.comments.add extractComment comment

proc getQuestion*(url: string): Future[Question] {.async.} =
  ## Update the `Question` by parsing the Brainly page
  result.url = url
  let
    client = newAsyncHttpClient(headers = newHttpHeaders({
      "User-Agent": mozilla,
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    }))
    html = parseHtml await client.getContent(url)
  close client

  block questionBox:
    let qbox = html.findAll("div", {"class": "brn-qpage-next-question-box"})[0]
    result.title = qbox.findAll("span", {"class": "sg-text sg-text--large sg-text--bold sg-text--break-words brn-qpage-next-question-box-content__primary"}).text
    result.body = qbox.findAll("span", {"class": "sg-text sg-text--break-words brn-qpage-next-question-box-content__secondary"}).text
    result.author = qbox.findAll("span", {"class": "sg-hide-for-small-only sg-text--small sg-text sg-text--link sg-text--bold sg-text--black"}).text
    result.avatar = qbox.findAll("div", {"class": "brn-qpage-next-question-box-header"})[0].
                      findAll("img", {"class": "sg-avatar__image"}).attr "src"
    block meta:
      let items = qbox.findAll("ul",{"class": "brn-horizontal-list"})[0]
      result.creation = parseInt items.findAll("time").attr "data-timestamp"
      result.subject = items.findAll("a", {"data-test": "question-box-subject"}).text
      result.grade = items.findAll("a", {"data-test": "question-box-grade"}).text

    block attachements:
      for attachement in qbox.findAll("div", {"class":"brn-qpage-next-attachments-viewer__active-item"}):
        let img = attachement.findAll("img").attr "src"
        if img.len > 0:
          result.attachments.add img
          continue
    block comments:
      for el in qbox.findAll("li", {"class":"brn-qpage-next-comments__list-item"}):
        result.comments.add extractComment el

  block answers:
    for el in html.findAll("div", {"class": "brn-qpage-next-answer-box js-answer"}):
      result.answers.add extractAnswer el

when isMainModule:
  import std/[json, jsonutils]
  # const url = "https://brainly.com/question/18649296"
  # const url = "https://brainly.com/question/24600056"
  # const url = "https://brainly.com.br/tarefa/36901808"
  # const url = "https://brainly.lat/tarea/56119687"
  const url = "https://brainly.ro/tema/7413901"
  var question = waitFor getQuestion url
  echo pretty question.toJson
