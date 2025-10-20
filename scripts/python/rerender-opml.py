#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
#import getopt
import argparse
import re
import time

#import xml
import xml.etree.ElementTree as ET

from io import StringIO
from lxml import etree

def writeOPML(filepath, contents):
  s = "\n".join(contents) + "\n"
  with open(filepath, "w") as f:
    f.write(contents)

def readFile(filepath):
  result = None
  contents = None
  fp = None
  try:
    fp = open(filepath, "r", encoding='UTF-8')
    contents = fp.read()
  finally:
    if fp != None:
      fp.close()

  if contents != None:
    result = contents

  return result

def writeFile(fullpath, contents):
  with open(fullpath, "w") as f:
    f.write(contents)

def transform(contents):
  data = None
  try:
    data = ET.fromstring(contents.encode("utf-8"))

  except ET.ParseError as e:
    pass

  except ValueError as e:
    pass

  except:
    pass

  if data == None:
    return None

  # Read version from input
  output_version = None
  for v in data.findall('./[@version]'):
    output_version = v.get("version")

  # Create a new document
  output = etree.Element("opml")

  # Parse head block
  for head in data.findall('.//head'):
    output_head = etree.Element("head")

    for t in head.findall('./title'):
      output_title = etree.Element("title")
      output_title.text = t.text
      output_head.append(output_title)

    for dc in head.findall('./dateCreated'):
      output_dateCreated = etree.Element("dateCreated")
      output_dateCreated.text = dc.text
      output_head.append(output_dateCreated)

    for dm in head.findall('./dateModified'):
      output_dateModified = etree.Element("dateModified")
      output_dateModified.text = dm.text
      output_head.append(output_dateModified)

    for on in head.findall('./ownerName'):
      output_ownerName = etree.Element("ownerName")
      output_ownerName.text = on.text
      output_head.append(output_ownerName)

    for oe in head.findall('./ownerEmail'):
      output_ownerEmail = etree.Element("ownerEmail")
      output_ownerEmail.text = oe.text
      output_head.append(output_ownerEmail)

    for oi in head.findall('./ownerId'):
      output_ownerId = etree.Element("ownerId")
      output_ownerId.text = oi.text
      output_head.append(output_ownerId)

    for d in head.findall('./docs'):
      output_docs = etree.Element("docs")
      output_docs.text = d.text
      output_head.append(output_docs)


  # Close head block
  output.append(output_head)

  xmlUrls = []

  outline_attr = [
    'type',
    'version',
    'language',
    'text',
    'title',
    'xmlUrl',
    'htmlUrl',
    'created',
    'modified',
    'description',
  ]

  skip_links = [
    r"\x2fcgi\x2dsys\x2fsuspendedpage\x2ecgi$",
  ]

  output_body = etree.Element("body")

  if data.findall('.//body/outline/outline'):

    output_outline = etree.Element("outline")

    for base_outline in data.findall('.//body/outline/outline'):

      xmlUrl = base_outline.get('xmlUrl')
      if xmlUrl != None:

        skip_this = False
        for skipli in skip_links:
          if re.search(skipli, str(xmlUrl), flags=re.IGNORECASE):
            skip_this = True

        if str(xmlUrl) not in xmlUrls and skip_this == False:
          outline = etree.Element("outline")
          xmlUrls.append(str(xmlUrl))

          for attr in outline_attr:
            if(
              base_outline.get(attr) != None
            and
              not re.search(r"^None$", base_outline.get(attr), flags=re.IGNORECASE)
            ):
              outline.set(attr, str(base_outline.get(attr)))

              # if attribute version is not set but attribute type are 'rss', set version to ''
              if base_outline.get('type') == 'rss':
                if base_outline.get('version') == None:
                  outline.set('version', "RSS2")

              # If attribute title is not set but are set in attribute text, copy
              if base_outline.get('text') != None and base_outline.get('title') == None:
                outline.set('title', str(base_outline.get('text')))
                if output_version != "2.0":
                  output_version = "2.0"

          output_outline.append(outline)

    output_body.append(output_outline)
  else:
    for base_outline in data.findall('.//body/outline'):

      xmlUrl = base_outline.get('xmlUrl')
      if xmlUrl != None:

        skip_this = False
        for skipli in skip_links:
          if re.search(skipli, str(xmlUrl), flags=re.IGNORECASE):
            skip_this = True

        if str(xmlUrl) not in xmlUrls and skip_this == False:
          outline = etree.Element("outline")
          xmlUrls.append(str(xmlUrl))

          for attr in outline_attr:
            if(
              base_outline.get(attr) != None
            and
              not re.search(r"^None$", base_outline.get(attr), flags=re.IGNORECASE)
            ):
              outline.set(attr, str(base_outline.get(attr)))

              # if attribute version is not set but attribute type are 'rss', set version to ''
              if base_outline.get('type') == 'rss':
                if base_outline.get('version') == None:
                  outline.set('version', "RSS2")

              # If attribute title is not set but are set in attribute text, copy
              if base_outline.get('text') != None and base_outline.get('title') == None:
                outline.set('title', str(base_outline.get('text')))
                if output_version != "2.0":
                  output_version = "2.0"

          output_body.append(outline)

  output.append(output_body)

  if output_version != None:
    output.set("version", str(output_version))

  opml_contents = etree.tostring(output, pretty_print=True, xml_declaration=True, encoding='UTF-8').decode()
  return opml_contents

def main():

  parser = argparse.ArgumentParser(
    prog='rerender-opml',
    description='Rerenders OPML to OPML to make sure it is XML-valid',
    epilog='Text at the bottom of help',
    add_help=False
  )
  
  parser.add_argument("-in", "--input", help="file to be read", required=True)
  parser.add_argument("-out", "--output", help="file to be written",required=False)
  parser.add_argument("-d", "--delete", help="delete input after processing",action="store_true", required=False, default=False)
  parser.add_argument("-q", "--quiet", help="No console",action="store_true", required=False, default=False)
  args = parser.parse_args()

  filepath_input = None
  filepath_output = None
  file_delete = None
  process_quiet = None

  if args.input:
    filepath_input = args.input

  if args.output:
    filepath_output = args.output

  if args.delete:
    file_delete = args.delete
  else:
    file_delete = False

  if args.quiet:
    process_quiet = args.quiet
  else:
    process_quiet = False

  if filepath_input != None:
    filecontents_input = readFile(filepath_input)

    if process_quiet == False:
      print(f"Read {len(filecontents_input)} bytes from file '{filepath_input}'")

    filecontents_output = transform(filecontents_input)

    if process_quiet == False:
      print(f"Re-rendered contents")

    if filecontents_output != None:
      if len(filecontents_output) > 0:
        writeOPML(filepath_output, filecontents_output)

      if process_quiet == False:
        print(f"Wrote {len(filecontents_output)} bytes to '{filepath_output}'")

    else:
      if process_quiet == False:
        print(f"Zero length result")

    if file_delete == True:
      os.unlink(filepath_input)

      if process_quiet == False:
        print(f"Deleted file {filepath_input} after processing")

if __name__ == '__main__':
  main()

