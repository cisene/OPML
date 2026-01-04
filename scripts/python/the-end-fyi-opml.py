#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import re
#import time
#import yaml
import json
import requests
import io
import yaml

import os
import sys
import re
import time

from datetime import datetime

from io import StringIO
from lxml import etree

from bs4 import BeautifulSoup

from datetime import datetime

from requests import Request, Session

BASE_URL = 'https://www.theend.fyi'

OPML_OWNER_NAME  = 'The End'
OPML_OWNER_EMAIL = 'updates@theend.fyi'

CACHE_JSON = '../cache-links.json'


global DEBUG
global SESS

global cache_links

def cacheLoad(filepath):
  contents = None
  with open(filepath, "r") as f:
    contents = f.read()
  return contents

def cacheSave(filepath, contents):
  with open(filepath, "w") as f:
    f.write(contents)

def stringFullTrim(data):
  data = re.sub(r"^\s{1,}", "", str(data), flags=re.IGNORECASE)
  data = re.sub(r"\s{1,}$", "", str(data), flags=re.IGNORECASE)
  data = re.sub(r"\s{2,}", " ", str(data), flags=re.IGNORECASE)
  return data

def writeOPML(filepath, contents):
  s = "\n".join(contents) + "\n"
  with open(filepath, "w") as f:
    f.write(contents)


def makeOPMLfilename(title):
  title = title.lower()

  title = re.sub(r"\b\x26\b", " ", str(title), flags=re.IGNORECASE)
  title = re.sub(r"\B\x26\B", " ", str(title), flags=re.IGNORECASE)
  title = re.sub(r"[^a-z0-9\s]", " ", str(title), flags=re.IGNORECASE)

  title = re.sub(r"^\s{1,}", "", str(title), flags=re.IGNORECASE)
  title = re.sub(r"\s{1,}$", "", str(title), flags=re.IGNORECASE)
  title = re.sub(r"\s{2,}", " ", str(title), flags=re.IGNORECASE)


  title = re.sub(r"\x20", "-", str(title), flags=re.IGNORECASE)

  title = f"the-end-fyi-{title}-feeds.opml"

  return title

def httpGET(url):
  global SESS

  SESS = requests.Session()

  headers = {
    'user-agent': 'OPML-scrape/#20260104 (@cisene@podcastindex.social)',
  }

  SESS.headers = headers

  res = SESS.get(url, headers=headers)

  return res

def buildOPML(collection):

  # Create a new document
  output = etree.Element("opml")

  # Create head block
  output_head = etree.Element("head")

  output_title = etree.Element("title")
  output_title.text = collection['title']
  output_head.append(output_title)

  output_url = etree.Element("url")
  output_url.text = collection['link']
  output_head.append(output_url)

  #output_dateCreated = etree.Element("dateCreated")
  #output_dateCreated.text = ""
  #output_head.append(output_dateCreated)

  #output_dateModified = etree.Element("dateModified")
  #output_dateModified.text = ""
  #output_head.append(output_dateModified)

  output_ownerName = etree.Element("ownerName")
  output_ownerName.text = OPML_OWNER_NAME
  output_head.append(output_ownerName)

  output_ownerEmail = etree.Element("ownerEmail")
  output_ownerEmail.text = OPML_OWNER_EMAIL
  output_head.append(output_ownerEmail)

  output_ownerId = etree.Element("ownerId")
  output_ownerId.text = "https://www.theend.fyi/creative/evo-terra"
  output_head.append(output_ownerId)

  # Close head block
  output.append(output_head)

  # Open body block
  output_body = etree.Element("body")

  for o in collection['outlines']:

    output_body_outline = etree.Element("outline")
    output_body_outline.set("type", "link")
    output_body_outline.set("version", "RSS")

    output_body_outline.set("title", o['title'])
    output_body_outline.set("text", o['title'])
    output_body_outline.set("htmlUrl", o['htmlUrl'])
    output_body_outline.set("xmlUrl", o['xmlUrl'])

    output_body.append(output_body_outline)

  # Close body block
  output.append(output_body)

  opml_contents = etree.tostring(output, pretty_print=True, xml_declaration=True, encoding='UTF-8').decode()
  return opml_contents


def scrapeShows(url):
  global cache_links

  result = {}
  res = httpGET(url)
  if res.status_code == requests.codes.ok:
    print(f"\tFetched '{url}' with status {res.status_code}")
    soup = BeautifulSoup(res.text, "lxml")

    for h1 in soup.find_all('h1'):
      h1_text = stringFullTrim(h1.text)
      break

    for div in soup.find_all('div'):
      if div.has_attr('fs-copyclick-text'):
        div_text = stringFullTrim(div.text)
        break

    for a in soup.find_all('a'):
      if a.has_attr('class'):
        if a.has_attr('target'):
          a_class = a.get('class')
          if "link-block-31" in a_class:
            a_href = a.get('href')
            break

    result = {
      'text': str(h1_text),
      'title': str(h1_text),
      'htmlUrl': str(a_href),
      'xmlUrl': str(div_text),
    }

  return result


def scrapeCollections(url):
  collection = {}
  collection['title'] = None
  collection['filename'] = None
  collection['link'] = url
  collection['shows'] = []
  collection['outlines'] = []

  res = httpGET(url)
  if DEBUG == True:
    print(f"Scraped collection at {url} with status {res.status_code}")

  if res.status_code == requests.codes.ok:
    soup = BeautifulSoup(res.text, "lxml")

    for h1 in soup.find_all('h1'):
      h1_text = stringFullTrim(h1.text)
      collection['title'] = h1_text
      collection['filename'] = makeOPMLfilename(h1_text)
      break

    for a in soup.find_all('a'):
      a_href = a.get('href')
      if a_href != "":
        
        if re.search(r"^https\x3a\x2f\x2fwww\x2etheend\x2efyi\x2fshows\x2f", str(a_href), flags=re.IGNORECASE):
          if str(a_href) not in collection['shows']:
            collection['shows'].append(str(a_href))

        if re.search(r"^\x2fshows\x2f([a-z0-9\x25\x26\x2d]{1,})", str(a_href), flags=re.IGNORECASE):
          scrape_link = f"{BASE_URL}{a_href}"
          if str(scrape_link) not in collection['shows']:
            collection['shows'].append(str(scrape_link))

  print(f"Found {len(collection['shows'])} Collection links ..\n")
  return collection

def scrapeIndex():
  url_list = []

  # Get the index
  url = 'https://www.theend.fyi/collections'
  res = httpGET(url)
  if DEBUG == True:
    print(f"Fecthed Index page '{url}' with status {res.status_code}")

  # Get the index
  if res.status_code == requests.codes.ok:
    soup = BeautifulSoup(res.text, "lxml")
    for a_link in soup.find_all('a'):
      a_href = a_link.get('href')
      if re.search(r"^\x2fcollection\x2f([a-z0-9\x2d]{1,})$", str(a_href), flags=re.IGNORECASE):
        scrape_link = f"{BASE_URL}{a_href}"
        if str(scrape_link) not in url_list:
          url_list.append(str(scrape_link))

  print(f"Found {len(url_list)} Collection links ..\n")
  sorted(url_list)
  return url_list


def main():
  global DEBUG
  global cache_links

  DEBUG = True

  cache_links = cacheLoad(CACHE_JSON)
  if cache_links == None:
    cache_links = {}

  collections = scrapeIndex()
  time.sleep(5)

  for collection in collections:
    collection = scrapeCollections(collection)

    if "outlines" not in collection:
      collection['outlines'] = []

    for show in sorted(collection['shows']):
      
      if show in cache_links:
        podcast = cache_links[show]
      else:
        podcast = scrapeShows(show)
        if show not in cache_links:
          cache_links[show] = podcast

      if podcast != None:
        collection['outlines'].append(podcast)

    opml = buildOPML(collection)
    if opml != None:
      opml_filename = f"../../{collection['filename']}"
      writeOPML(opml_filename, opml)

    #exit(0)

  cacheSave(CACHE_JSON, json.dumps(cache_links))

  print("Done!")



if __name__ == '__main__':
  main()

