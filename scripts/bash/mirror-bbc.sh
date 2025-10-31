#!/usr/bin/env bash

function fetchToDisk {
  wget --quiet --tries=3 --timeout=10 --dns-timeout=5 --connect-timeout=5 --read-timeout=10 -O "temp.opml" "$1"
}

function delint {
  if [ ! -f "temp.opml" ]; then
      echo "temp.opml does not exist."
      return
  fi

  cat temp.opml | xmllint --nonet --noent --recover --xmlout --format - > "$1"
}

function mirrorTimestamp {
  echo "$(date --utc --iso-8601=seconds)Z"
}

function removeTemp {
  rm temp.opml
}

function fixCharacters {
  # Truncate strings of 2 or more spaces to a single space
  sed -i "s|\s{2,}| |gi" "$1"

  # Degree symbol
  sed -i "s|\xb0|&deg;|gi" "$1"

  # NDASH
  sed -i "s|\x26amp\x3bndash\x3b|\&ndash;|gi" "$1"

  # APOS 
  #sed -i "s|\x27|\&apos;|gi" "$1"
  sed -i "s|\x26\x2339\x3b|\&apos;|gi" "$1"

  #sed -i "s|\x26amp\x3b|\&amp;|gi" temp.opml
  #sed -i "s|\b\x26(?!(.+?)\x3b)\b|\&amp;|gi" temp.opml
  #sed -i "s|\s\x26\s| \&amp; |gi" temp.opml

  # Double double-quotes - breaks XML
  sed -i "s|\x22\x22|\"|gi" "$1"


  # AMP - Naked ampersand between two words separated by space
  sed -i "s|\s\x26\s| \&amp; |gi" "$1"
}

function fixCharacterAmpersand {
  # AMP - Escape ampersant in links
  sed -i "s#\b\x26\b#&amp;#gi" "$1"

  # AMP - Escape stuff that hasn't been escaped already
  sed -i "s#\x26(?!(?:apos|quot|[gl]t|amp|deg)\x3b|#)#&amp;#gi" "$1"
}

function fixXMLDecl {
  # Change single quotes to double quotes on XML encoding declaration
  sed -i "s|encoding\x3d\x27UTF\x2d8\x27|encoding=\"UTF-8\"|gi" "$1"
}

function fixXMLStylesheet {
  # Remove simple stylesheet inclusion
  sed -i "s|\x3c\x3fxml\x2dstylesheet\stype\x3d\x22text\x2fxsl\x22\shref\x3d\x22(.+?)\x22\x3f\x3e||gi" "$1"
  sed -i "s|\x3c\x3fxml\x2dstylesheet\shref\x3d\x22(.+?)\x22\stype\x3d\x22text\x2fxsl\x22\x3f\x3e||gi" "$1"

  sed -i "s|\x3c\x3fxml\x2dstylesheet\stype\x3d\x22text\x2fxsl\x22\shref\x3d\x22.+?\x22\x3f\x3e||gi" "$1"

}

function fixOPMLDecl {
  # Change single quotes to double quotes on XML version declaration
  sed -i "s|version\x3d\x271\x2e0\x27|version=\"1.0\"|gi" "$1"

  # Change single quotes to double quotes on XML and OPML declaration
  sed -i "s|version\x3d\x271\x2e1\x27|version=\"1.1\"|gi" "$1"

  # Change single quotes to double quotes on XML and OPML declaration
  sed -i "s|version\x3d\x272\x2e0\x27|version=\"2.0\"|gi" "$1"

  # Replace single-quotes with double-quotes on OPML root element
  sed -i "s|\x3copml\sversion\x3d\x271\x2e0\x27\x3e|<opml version=\"1.0\">|gi" "$1"
  sed -i "s|\x3copml\sversion\x3d\x271\x2e1\x27\x3e|<opml version=\"1.1\">|gi" "$1"
  sed -i "s|\x3copml\sversion\x3d\x272\x2e0\x27\x3e|<opml version=\"2.0\">|gi" "$1"
}


function fixXML {
  # Replace tab characters with spaces
  sed -i "s|\t{1,}| |gi" "$1"

  # /&gt; - Strange sequence
  sed -i "s|\x22\s{1,}\x2f\x26gt\x3b\s{1,}\x22|\"\"|gi" "$1"

  sed -i "s|\stext\x3d\x22\x22| text=\"Podcast\"|gi" "$1"

  # Remove empty description attribute
  sed -i "s|\sdescription\x3d\x22\x22||gi" "$1"

  # Adjust XML declaration to be standalone=yes
  sed -i "s|standalone\x3d\x22no\x22|standalone=\"yes\"|gi" "$1"
}

function removeEmptyHtmlUrl {
  # Remove empty htmlUrl
  sed -i "s|\shtmlUrl\x3d\x22\x22||gi" "$1"
}

function removeUTMTracking {

  # Term
  sed -i "s|\x26utm\x5fterm\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"
  
  # Content
  sed -i "s|\x26utm\x5fcontent\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"
  
  # Campaign
  sed -i "s|\x26utm\x5fcampaign\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"

  # Medium
  sed -i "s|\x26utm\x5fmedium\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"

  # Source
  sed -i "s|\x26utm\x5fsource\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"
  sed -i "s|\x3futm\x5fsource\x3d([a-z0-9\x25\x2d]{1,})||gi" "$1"
}


function removeURLFragments {
  # Strip out GOOGLE_ABUSE_EXEMPTION
  sed -i "s|^http(s)?\x3a\x2f\x2f(.+?)(\x3f|\x26)google\x5fabuse\x3dGOOGLE\x5fABUSE\x5fEXEMPTION\x253DID\x253D(.*)|http$1://$2|gi" "$1"

  # Strip out "nw=0"
  sed -i "s|^http(s)?\x3a\x2f\x2f(.+?)(\x3f|\x26)nw\x3d\d{1,}|http$1://$2|gi" "$1"

  # Strip out "format=MP3_xxxK"
  sed -i "s|^http(s)?\x3a\x2f\x2f(.+?)(\x3f|\x26)format\x3dMP3\x5f\d{1,}K|http$1://$2|gi" "$1"

  # Strip out subscription keys (private subscriptions) "?key=asdf12345678"
  sed -i "s|\x3fkey\x3d([a-z0-9]{12})||gi" "$1"
}

function removeStylesheet {
  # stylesheet reference (type, href)
  sed -i "s|\x3c\x3fxml\x2dstylesheet\stype\x3d\x22text\x2fxsl\x22\shref\x3d\x22(.+?)\x22\x3f\x3e\n||gi" "$1"

  # stylesheet referenct (href, type)
  sed -i "s|\x3c\x3fxml\x2dstylesheet\shref\x3d\x22(.+?)\x22\stype\x3d\x22text\x2fxsl\x22\x3f\x3e\n||gi" "$1"
}

function addMirrorTag {
  TIMESTAMP="$(date --iso-8601=seconds)Z"

  # OPML 1.0
  sed -i "s|\x3copml\x20version\x3d\x221\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/bbc/$2 -->\n<opml version=\"1.0\">|gi" "$2"

  # OPML 1.1
  sed -i "s|\x3copml\x20version\x3d\x221\x2e1\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/bbc/$2 -->\n<opml version=\"1.1\">|gi" "$2"

  # OPML 2.0
  sed -i "s|\x3copml\x20version\x3d\x222\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/bbc/$2 -->\n<opml version=\"2.0\">|gi" "$2"
}

function MirrorOPML {
  echo "Mirroring '$1' to '$2'"
  fetchToDisk "$1"
  #fixXMLDecl "temp.opml" "$2"
  #fixXMLStylesheet "temp.opml" "$2"
  #fixOPMLDecl "temp.opml" "$2"
  #fixXML "temp.opml" "$2"

  #removeUTMTracking "temp.opml"

  #fixCharacterAmpersand "temp.opml"

  #removeURLFragments "temp.opml"
  #removeStylesheet "temp.opml"
  #removeEmptyHtmlUrl "temp.opml"

  #fixCharacters "temp.opml" "$2"

  delint "$2"
  #python3 scripts/python/rerender-opml.py -in "temp.opml" -out "$2" -d
  addMirrorTag "$1" "$2"
  removeTemp
}

MirrorOPML "http://www.bbc.co.uk/podcasts.opml" "bbc-co-uk-podcasts.opml"
MirrorOPML "http://news.bbc.co.uk/rss/feeds.opml" "bbc-co-uk-news-rss-feeds.opml"
MirrorOPML "https://podcasts.files.bbci.co.uk/podcasts.opml" "bbci-co-uk-podcasts.opml"
