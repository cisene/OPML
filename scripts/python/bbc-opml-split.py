#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import re
#import time
#import yaml
#import json
#import requests
#import time

import xml.etree.ElementTree as ET

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

def fixTitle(data):
  result = None
  translate_table = {
    'BBC World Service':            'BBC World Service',
    'BBC Radio Cymru':              'BBC Radio Cymru',
    'BBC Radio 3':                  'BBC Radio 3',
    'BBC Radio Ulster':             'BBC Radio Ulster',
    'BBC Radio 4':                  'BBC Radio 4',
    'BBC Radio 5 Live':             'BBC Radio 5 Live',
    'BBC Radio Scotland':           'BBC Radio Scotland',
    'BBC Radio nan Gàidheal':       'BBC Radio nan Gàidheal',
    'BBC Brasil':                   'BBC Radio Brasil',
    'BBC Hindi Radio':              'BBC Radio Hindi',
    'BBC Gahuza Radio':             'BBC Radio Gahuza',
    'CBeebies Radio':               'BBC Radio CBeebies',
    'BBC Marathi Audio':            'BBC Radio Marathi Audio',
    'BBC Radio Leicester':          'BBC Radio Leicester',
    'BBC News':                     'BBC Radio News',
    'BBC Radio Derby':              'BBC Radio Derby',
    'BBC Radio 1':                  'BBC Radio 1',
    'BBC Radio Suffolk':            'BBC Radio Suffolk',
    'BBC Radio':                    'BBC Radio Web-only',
    'BBC Nepali Radio':             'BBC Radio Nepali',
    'BBC Burmese Radio':            'BBC Radio Burmese',
    'BBC Radio Wales':              'BBC Radio Wales',
    'BBC Radio Oxford':             'BBC Radio Oxford',
    'BBC Newcastle':                'BBC Radio Newcastle',
    'BBC Radio 2':                  'BBC Radio 2',
    'BBC Russian Radio':            'BBC Radio Russian',
    'BBC Radio Northampton':        'BBC Radio Northampton',
    'BBC Radio 1Xtra':              'BBC Radio 1Xtra',
    'BBC Sounds':                   'BBC Sounds Podcasts',
    'BBC Radio Lincolnshire':       'BBC Radio Lincolnshire',
    'BBC Radio Sheffield':          'BBC Radio Sheffield',
    'BBC Radio Berkshire':          'BBC Radio Berkshire',
    'BBC Radio Merseyside':         'BBC Radio Merseyside',
    'BBC Kyrgyz Radio':             'BBC Radio Kyrgyz',
    'BBC Persian Radio':            'BBC Radio Persian',
    'BBC Radio Cumbria':            'BBC Radio Cumbria',
    'BBC Local Radio':              'BBC Radio Local',
    'BBC Learning English':         'BBC Radio Learning English',
    'BBC Radio Cornwall':           'BBC Radio Cornwall',
    'BBC Sussex':                   'BBC Radio Sussex',
    'BBC Radio Cambridgeshire':     'BBC Radio Cambridgeshire',
    'BBC Radio Manchester':         'BBC Radio Manchester',
    'BBC Scotland':                 'BBC Radio Scotland',
    'BBC Radio Norfolk':            'BBC Radio Norfolk',
    'BBC Radio Leeds':              'BBC Radio Leeds',
    'BBC Essex':                    'BBC Radio Essex',
    'BBC Radio Jersey':             'BBC Radio Jersey',
    'BBC Radio Kent':               'BBC Radio Kent',
    'BBC Radio 6 Music':            'BBC Radio 6 Music',
    'BBC Radio Lancashire':         'BBC Radio Lancashire',
    'BBC Radio York':               'BBC Radio York',
    'BBC Radio Nottingham':         'BBC Radio Nottingham',
    'BBC':                          'BBC',
    'BBC Radio London':             'BBC Radio London',
    'BBC Tees':                     'BBC Radio Tees',
    'BBC Somerset':                 'BBC Radio Somerset',
    'BBC Coventry & Warwickshire':  'BBC Radio Coventry & Warwickshire',
    'BBC Three Counties Radio':     'BBC Radio Three Counties',
    'BBC Wiltshire':                'BBC Radio Wiltshire',
    'BBC Radio Gloucestershire':    'BBC Radio Gloucestershire',
    'BBC Radio Stoke':              'BBC Radio Stoke',
    'BBC Radio Shropshire':         'BBC Radio Shropshire',
    'BBC Hereford & Worcester':     'BBC Radio Hereford & Worcester',
    'BBC Radio Bristol':            'BBC Radio Bristol',
    'BBC Arabic Radio':             'BBC Radio Arabic',
    'BBC Asian Network':            'BBC Radio Asian Network',
    'BBC Indonesia Radio':          'BBC Radio Indonesia',
    'BBC Ukrainian Audio':          'BBC Radio Ukrainian Audio',
    'BBC Cantonese Radio':          'BBC Radio Cantonese',
    'BBC Radio 4 Extra':            'BBC Radio 4 Extra',
    'BBC Urdu Radio':               'BBC Radio Urdu',
    'BBC WM 95.6':                  'BBC Radio WM 95.6',
    'BBC Arts':                     'BBC Arts',
    'CBBC':                         'BBC Radio CBBC',
    'BBC Radio Humberside':         'BBC Radio Humberside',
    'BBC Radio Solent':             'BBC Radio Solent',
    'BBC Hausa Radio':              'BBC Radio Hausa',
    'BBC Radio Devon':              'BBC Radio Devon',
    'School Radio':                 'BBC Radio School',
    'BBC Cymru':                    'BBC Radio Cymru',
    'BBC Radio Foyle':              'BBC Radio Foyle',
    'BBC World Service for Africa': 'BBC World Service Africa',
    'BBC Tamil Radio':              'BBC Radio Tamil',

  }

  if data in translate_table:
    result = translate_table[data]
  #else:
    #print(f"entry '{data}' was not in lookup table")
    #exit(0)

  return result

def fixFilename(data):
  data = data.lower()
  data = re.sub(r"\x20", "-", str(data), flags=re.IGNORECASE)
  data = re.sub(r"\x2e", "-", str(data), flags=re.IGNORECASE)

  data = re.sub(r"\x2d\x26\x2d", "-", str(data), flags=re.IGNORECASE)

  data = re.sub(r"\x2d{2,}", "-", str(data), flags=re.IGNORECASE)
  return data

def writeFile(fullpath, contents):
  with open(fullpath, "w") as f:
    f.write(contents)

def htmlEncode(data):
  data = re.sub(r"\x20\x26\x20", " &amp; ", str(data), flags=re.IGNORECASE)
  data = re.sub(r"\x27", "&acute;", str(data), flags=re.IGNORECASE)
  data = re.sub(r"\x22", "&quote;", str(data), flags=re.IGNORECASE)

  data = re.sub(r"\s{2,}", " ", str(data), flags=re.IGNORECASE)

  return data

def urlUpgrade(data):
  if re.search(r"^http\x3a\x2f\x2f", str(data), flags=re.IGNORECASE):
    data = re.sub(r"^http\x3a\x2f\x2f", "https://", str(data), flags=re.IGNORECASE)

  return data

def parseOPML(contents):
  links = []

  try:
    data = ET.fromstring(contents.encode("utf-8"))

  except ET.ParseError as e:
    pass

  except ValueError as e:
    pass

  except:
    pass

  for head in data.findall('.//head'):
    for dc in head.findall('./dateCreated'):
      opml_dateCreated = dc.text
    for dm in head.findall('./dateModified'):
      opml_dateModified = dm.text

  for base_outline in data.findall('.//body/outline'):
    #print(base_outline.get('text'))

    skip_list = [
      'BBC',
    ]

    for inner_outline in base_outline.findall('./outline'):
      opml_title = fixTitle(inner_outline.get('text'))

      if inner_outline.get('text') in skip_list:
        continue

      opml_filename = fixFilename(opml_title)
      opml_fullpath = f"../../{opml_filename}.opml"

      # Done deriving filename, let's encode ..
      opml_title = htmlEncode(opml_title)


      st = []
      st.append(f"<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
      st.append(f"<opml version=\"1.1\">")
      st.append(f"  <head>")
      st.append(f"    <title>{opml_title}</title>")
      st.append(f"    <dateCreated>{opml_dateCreated}</dateCreated>")
      st.append(f"    <dateModified>{opml_dateModified}</dateModified>")
      st.append(f"    <ownerName>BBC Audio &amp; Music</ownerName>")
      st.append(f"    <ownerEmail/>")
      st.append(f"  </head>")
      st.append(f"  <body>")

      for ol in inner_outline.findall('./outline'):
        ol_type = ol.get('type')
        ol_version = ol.get('version')
        ol_language = ol.get('language')
        ol_text = htmlEncode(ol.get('text'))
        ol_description = htmlEncode(ol.get('description'))
        ol_xmlUrl = urlUpgrade(ol.get('xmlUrl'))
        ol_htmlUrl = urlUpgrade(ol.get('htmlUrl'))
        st.append(f"    <outline type=\"{ol_type}\" version=\"{ol_version}\" language=\"{ol_language}\" xmlUrl=\"{ol_xmlUrl}\" htmlUrl=\"{ol_htmlUrl}\" text=\"{ol_text}\" description=\"{ol_description}\" />")

      st.append(f"  </body>")
      st.append(f"</opml>")

      rendered = "\n".join(st)

      if not os.path.exists(opml_fullpath):
        writeFile(opml_fullpath, rendered)
      else:
        os.remove(opml_fullpath)
        writeFile(opml_fullpath, rendered)


def main():

  file = '../../bbc-co-uk-podcasts.opml'

  contents = readFile(file)
  parseOPML(contents)



if __name__ == '__main__':
  main()

