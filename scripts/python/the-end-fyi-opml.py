#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import re
#import time
#import yaml
#import json
import requests
#import time
import io
import yaml

import os
import sys
import re

from datetime import datetime

from io import StringIO
#from lxml import etree
from lxml import etree
#from xml.etree.ElementTree import XML, fromstring

from bs4 import BeautifulSoup

from datetime import datetime

from requests import Request, Session

BASE_URL = 'https://www.theend.fyi'

global SESS

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
    'user-agent': 'OPML-scrape/#20250908 (@cisene@podcastindex.social)',
  }

  SESS.headers = headers

  res = SESS.get(url, headers=headers)

  return res

def scrape():
  url_list = []

  # Get the index
  url = 'https://www.theend.fyi/collections'
  res = httpGET(url)
  #print(res.text)

  if res.status_code == requests.codes.ok:
    #print(res.status_code)

    soup = BeautifulSoup(res.text, "lxml")

    for a_link in soup.find_all('a'):
      a_href = a_link.get('href')
      if re.search(r"^\x2fcollection\x2f([a-z0-9\x2d]{1,})$", str(a_href), flags=re.IGNORECASE):
        scrape_link = f"{BASE_URL}{a_href}"
        #print(scrape_link)
        if str(scrape_link) not in url_list:
          url_list.append(str(scrape_link))
      else:
        #print(f"Missed: '{a_href}'")
        pass

  sorted(url_list)
  
  for url in url_list:
    print("")
    print(url)
    res = httpGET(url)

    if res.status_code == requests.codes.ok:
      #print(res.status_code)

      # Open OPML
      opml = etree.Element("opml", version = "1.0")

      # Open Head
      head = etree.SubElement(opml, "head")


      # Drill html
      soup = BeautifulSoup(res.text, "lxml")

      # Find H1
      for h1 in soup.find_all('h1'):
        opml_title = h1.text

      # Generate filename from title
      opml_filename = makeOPMLfilename(opml_title)

      # Handle Title
      opml_title_text = f"RSS feeds for shows in the {opml_title} Collection on TheEnd.fyi"
      title = etree.Element("title")
      title.text = str(opml_title_text)
      head.append(title)

      opml.append(head)

      body = etree.Element("body")

      outline_outer = etree.Element("outline")
      outline_outer.set("text", "Feeds")

      # Get all links - RSS resources
      for link in soup.find_all('link'):
        link_href = link.get('href')
        link_title = link.get('title')

        if(
          link_title != None
        and
          link_title not in ['RSS Feed', 'The latest articles published']
        and
          not re.search(r"^https\x3a\x2f\x2fwww\x2etheend\x2efyi", str(link_href), flags=re.IGNORECASE)
        and
          link_href != ""
        and
          link_href != None
        ):
          outline_inner = etree.Element("outline")
          outline_inner.set("text", str(link_title))
          outline_inner.set("title", str(link_title))
          outline_inner.set("type", "rss")
          outline_inner.set("xmlUrl", str(link_href))
          outline_outer.append(outline_inner)

      # Add outer outline to body
      body.append(outline_outer)

      # Close body
      opml.append(body)

      opml_contents = etree.tostring(opml, pretty_print=True, xml_declaration=True, encoding='UTF-8').decode()
      writeOPML(f"./{opml_filename}", opml_contents)

      print(f"Wrote {opml_filename} ..")


def main():

  scrape()



if __name__ == '__main__':
  main()

