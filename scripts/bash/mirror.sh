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
  sed -i "s|\x3copml\x20version\x3d\x221\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"1.0\">|gi" "$2"

  # OPML 1.1
  sed -i "s|\x3copml\x20version\x3d\x221\x2e1\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"1.1\">|gi" "$2"

  # OPML 2.0
  sed -i "s|\x3copml\x20version\x3d\x222\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"2.0\">|gi" "$2"
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
  addMirrorTag "$1" "$2"
  removeTemp
}

MirrorOPML "http://www.cbc.ca/podcasts.opml" "cbc-ca-podcasts.opml"

#MirrorOPML "http://edition.cnn.com/services/podcasting/CNN.opml" "cnn-edition.opml"

#MirrorOPML "http://www.bbc.co.uk/podcasts.opml" "bbc-co-uk-podcasts.opml"
#MirrorOPML "http://news.bbc.co.uk/rss/feeds.opml" "bbc-co-uk-news-rss-feeds.opml"
#MirrorOPML "https://podcasts.files.bbci.co.uk/podcasts.opml" "bbci-co-uk-podcasts.opml"

MirrorOPML "http://www.gigadial.net/public/opml/" "gigadial-pod.opml"

MirrorOPML "https://www.rtl.fr/podcasts.opml" "rtl-fr-podcasts.opml"

MirrorOPML "https://www.apapodcast.cz/podcast.opml" "apapodcast-cz-podcast.opml"

#MirrorOPML "https://www.ibm.com/ibm/syndication/podcasts/us/en/index.opml" "ibm-podcasts.opml"

#MirrorOPML "https://stats.podcastindex.org/v4vmusic.opml" "podcastindex-org-value4value-music.opml"

MirrorOPML "https://feeds.twit.tv/twitfeeds.opml" "twit-tv-twitfeeds.opml"
MirrorOPML "https://feeds.twit.tv/twitshows.opml" "twit-tv-twitshows.opml"
MirrorOPML "https://feeds.twit.tv/twitshows_video_hd.opml" "twit-tv-twitshows-video-hd.opml"

MirrorOPML "https://iosdevdirectory.com/opml/en/podcasts.opml" "iosdevdirectory-english-podcasts.opml"
MirrorOPML "https://iosdevdirectory.com/opml/es/podcasts.opml" "iosdevdirectory-spanish-podcasts.opml"
MirrorOPML "https://iosdevdirectory.com/opml/de/podcasts.opml" "iosdevdirectory-german-podcasts.opml"

MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder-aegrumet.opml" "ipodder-sourceforge-net-ipodder-aegrumet.opml"
MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder-gtk.opml" "ipodder-sourceforge-net-ipodder-gtk.opml"
MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder.opml" "ipodder-sourceforge-net-ipodder.opml"

MirrorOPML "http://s3.amazonaws.com/radio2/communityReadingList.opml" "radio2-communityReadingList.opml"

MirrorOPML "http://podcasts.divergence-fm.org/podcasts.opml" "divergence-fm-podcasts.opml"

MirrorOPML "http://hosting.opml.org/petercook/CBC/podcasts/CanadaLive.opml" "petercook-cbc-podcasts-canadalive.opml"
MirrorOPML "http://ladyofsituations.com/custom/people.opml" "ladyofsituations-custom-people.opml"
MirrorOPML "http://nevillehobson.com/pubfiles/060508-NH-primary1-exp.opml" "nevillehobson-com-060508-NH-primary1-exp.opml"
MirrorOPML "http://rasterweb.net/raster/feeds/wisconsin.opml" "rasterweb-net-wisconsin.opml"
MirrorOPML "http://rss.sina.com.cn/sina_all_opml.xml" "sina-com-cn-all.opml"
MirrorOPML "http://www.marshallk.com/politicalaudio.aspx.xml" "marshalls-politicalaudio.opml"
MirrorOPML "https://ainali.com/listening/feed.opml" "ainali-listening.opml"
MirrorOPML "https://chillr.de/wp-content/uploads/Podcast20150707.opml" "chillr-de-podcast20150707.opml"
MirrorOPML "https://chrisabraham.com/opml/at_download/file" "chrisabreaham.opml"
MirrorOPML "https://dave.sobr.org/enc/1662343807.433_polishpodcastdirectoryopml.xml" "podkasty-info-katalog-podkastow.opml"
MirrorOPML "https://dhruv-sharma.ovh/files/podcasts.opml" "dhruv-sharma.opml"
MirrorOPML "https://digiper.com/dl/digiper.opml" "digiper.opml"
MirrorOPML "https://inkdroid.org/podcasts/feed.opml" "inkdroid-podcasts.opml"
MirrorOPML "https://jchk.net/files/Podcasts.opml" "jchk-net-podcasts.opml"
MirrorOPML "https://kowalcj0.github.io/2020/03/22/files/podcasts.opml" "kowalcj0-20200322-podcasts.opml"
MirrorOPML "https://redecentralize.org/redigest/2022/kthxbye/redigest_feed_recommendations.opml" "redecentralize-redigest-feed-reccommendations.opml"
MirrorOPML "https://soenke-scharnhorst.de/files/overcast.opml" "soenke-scharnhorst-overcast.opml"
MirrorOPML "https://typlog.com/podlist/opml.xml" "typlog-pod.opml"
MirrorOPML "https://welcometochina.com.au/wp-content/uploads/china-podcasts.opml" "welcomtochina-china-podcasts.opml"
MirrorOPML "https://www.apapodcast.cz/podcast.opml" "apapodcast-cz-podcast.opml"
MirrorOPML "https://www.apreche.net/~apreche/podcasts.opml" "apreche-podcasts.opml"
MirrorOPML "https://www.ironnysh.com/assets/podcasts-subs.opml" "ironnysh-com-podcasts-subs.opml"

MirrorOPML "https://fyyd.de/user/altf4/collection/deutsch/opml" "fyyd-de-altf4-collection-deutsch.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/azhempfehlungen/opml" "fyyd-de-dirkprimbs-empfehlungen-der-anerzaehlt-hoerer.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/fotografiepodcasts/opml" "fyyd-de-dirkprimbs-collection-fotografiepodcasts.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/podcastpodcasts/opml" "fyyd-de-dirkprimbs-collection-podcastpodcasts.opml"
MirrorOPML "https://fyyd.de/user/eazy/collection/morning-podcast/opml" "fyyd-de-eazy-morning-podcast.opml"
MirrorOPML "https://fyyd.de/user/eazy/collection/us-daily/opml" "fyyd-de-eazy-us-daily.opml"
MirrorOPML "https://fyyd.de/user/emolotow/collection/f361eea6f2288b3b565324885c91290a/opml" "fyyd-de-emoltow-collection.opml"
MirrorOPML "https://fyyd.de/user/ferdicharms/collection/868d2e0900e4005aef08b7ca76f1057c/opml" "fyyd-de-ferdicharms-podcast-episoden.opml"
MirrorOPML "https://fyyd.de/user/garneleh/collection/audiospass-fuer-kids-und-co/opml" "fyyd-de-garneleh-collection-audiospass-fuer-kids-und-co.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/hoersuppe/opml" "fyyd-de-hoersuppe-hoersuppe.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/holgis-podcasts/opml" "fyyd-de-hoersuppe-holgis.opml"
MirrorOPML "https://fyyd.de/user/iwmm/collection/77c5dd6f7db4444989918a5726b90255/opml" "fyyd-de-iwmm-soziale-arbeit.opml"
MirrorOPML "https://fyyd.de/user/Maddin/collection/maddins-liebste-podcasts/opml" "fyyd-de-maddins-liebste-podcasts.opml"
MirrorOPML "https://fyyd.de/user/molldur/collection/echal23/opml" "fyyd-de-molldur-educamp-2023-halle.opml"
MirrorOPML "https://fyyd.de/user/palatinatemike/collection/4d2ca352af5091e2ee7863fa17f91f5e/opml" "fyyd-de-palatinatemike-meine-podcast-roll-12-2022.opml"
MirrorOPML "https://fyyd.de/user/Podcastsumpf/collection/bc3b7767b3e4be2d6f129767808d9582/opml" "fyyd-de-im-podcastsumpf-die-auserwahlten.opml"
MirrorOPML "https://fyyd.de/user/RikschaAndi/collection/1822f29e8fb27d595dacae3aa3366e7c/opml" "fyyd-de-sport-collection-for-rikschaandi.opml"
MirrorOPML "https://fyyd.de/user/shiller/collection/podstock2019/opml" "fyyd-de-shiller-podstock-2019.opml"
MirrorOPML "https://fyyd.de/user/thrommel/collection/71a74d21870cb8abc532b809ba36ca26/opml" "fyyd-de-thrommels-podcatcher.opml"

MirrorOPML "https://gist.githubusercontent.com/2KAbhishek/2abf301bdb60c972457e5109fc99ed1c/raw/e13eeb8d821bdf2091e9fe0f46a5286bc3b2b19d/Podcasts.opml.xml" "2KAbhishek-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/abloch/8043591/raw/37344486529c74834fbc879955649b32bdb978ea/podcasts.opml" "abloch-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/aerosol/c3ec8ab5dddb736758762119af8da6db/raw/3ca23f92cb3b3cabeb73955f7c09f4d39ba3e6c8/podcasts.opml" "aerosol-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/barrieselack/6164714/raw/8eefb665b812c8bffee881ea4604a5991c7d4823/podcasts.opml" "barrieselack-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/christophermoura/d8c99f499244c55eca2081e18456bf49/raw/14e74858a2ad6188d1cad6db9cc96e266686089a/podcasts.opml" "christophermoura-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/ciwchris/b204fbbca6f240b0cf2e789797355e60/raw/878debb59e4885d7ff798214ce346e937a596962/podcast.opml" "ciwchris-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/cledoux/1c1d0b772b275b4a23b26f71f1cc55b2/raw/c96d3fd7f530ccdd27edb4df0820400205141299/podcasts_opml.xml" "cledoux-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/coderabbi/e7a6b11971b52239ab676abf92517a79/raw/3dbaadf72ecc805d7ae7c771394d0dcfc3af39b4/coderabbi.opml" "coderabbi-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/DamianStanger/9606fcf3fb09cc0bd87f/raw/de6bbc5faf6a124e17a5567a7d7b96aafc84acfb/podcasts.opml" "damianstanger-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/empireshades/cfb7a0b0eb84ec90bf5dc99771a1f707/raw/f386cab2617f477c4eca2b397ed664b816855d24/my_podcasts.opml" "empireshades-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/endorphin82/452ef97f91b5364b2e2b2efa52b5a9cf/raw/69ade652d225477e63d352c0626827e8bafe7f9d/podcasts.opml" "endorphine82-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/extratone/d63e7bb819eef1d5cb5991f83d6052d2/raw/09d0747fcbd51a7e9ab011a21cf8f3eecae7d603/podcasts.opml" "extratone-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/fabienhinault/84ad5b0b791ab9aa97f149f9fe93a51a/raw/1ba2b314f106326772895e295b30312685ef294e/Podcasts.opml" "fabienhinault-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/farski/9340648/raw/628d0a962eaecc87504e7f77645f5ca542d76622/Podcasts.opml" "farski-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/fvonx/5cf40509f09bde1e8c35c5de239a9a0d/raw/74ae260357b71a4d76c342d5b3058c163616f4ca/podcasts.opml" "fvonx-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/GraemeF/7596315/raw/ebfe3357e26dc2f18af72f4947d9799df248bc34/Podcasts.opml" "graemef-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/hubner/a663e2a59e2dbedd2916ec8148c8c82d/raw/29bf898fa36384676a3ef7ee29f32fd237f084ec/overcast.opml" "hubner-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/jacquesfunk/d4e66793718a74fba7be/raw/45403fc33b0ade2714d43b12426560f98c475231/gistfile1.txt" "jacquesfunk-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/jamesstout/a4050fdfda4f1fad5d5637ff35293549/raw/327bf85c18aec2834f4af1aafe8cbd52441ce389/overcast.opml" "jamesstout-example-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/johngian/bb0987924a3f656b1cf9711e82eca95f/raw/fde5824cd8938edbf57e40a6024de6f43e664882/nemoworld-podcasts%2520OPML" "johngian-nemoworld-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/jonschoning/6c3ad070f70bc55fe08b51b72f27d7b8/raw/40395dca56d29d8320d31e273d1d14e268602634/podcasts.opml" "jonschoning-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/kobusb/c48256a031ee8cadbdf26d6595d73eee/raw/7d855551365000f52a9da36bf75615b8698748fc/podcasts.opml" "kobusb-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/lerrua/399943/raw/76eb1921aabc492a36a0b8484de366053039c811/podcasts.opml" "lerrua-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/matoken/722ae6435e22fd8d7bd1/raw/249453df0f891e139690d873958cf04dec3bc046/podcast.opml" "matoken-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/mcepl/1699090/raw/8eefb665b812c8bffee881ea4604a5991c7d4823/podcasts.opml" "mcepl-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/mrpnkt/2cea91307c6d9b96a68527d5841f8d38/raw/4f440ef8689a1ff08b93a6ddfba17086d3c2166d/security_podcasts.opml" "mrpnkt-security-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/OdinsHat/36855a2b4c76f8109428ba05e163e30e/raw/080b288682368dfc972ce2e4151c88393e9f37ae/castbox-opml-nov-19.xml" "OdinsHat-castbox-opml-nov-19-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/panuta/65902f092d4619fe0ed0/raw/354d75d67820869b321ceb0b8a791155c51483c7/gistfile1.txt" "panuta-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/pbgnz/fff797e2b2d65722d838d4ee9e5710c0/raw/d289d1414991b393181b4b0e55987efe7d7dcc3a/podcasts.opml" "pbgnz-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/quinncomendant/c3bdc7ed21b35bc52dfcf0c328538959/raw/e3332c76b6f1233aafdfbbba9738792e157cfbd3/podcasts.opml" "quinncomendant-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/reinaldocoelho/a91ab015ea1bb4a14c21a7cbf43fd745/raw/9260211fdc3f2d368a077f8faedad5d27e19ce2d/gPodder-podcasts.opml" "reinaldocoelho-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/robbieferrero/f4db4ca74f0e0c6638a6e59f2aca505e/raw/710d82f6d8522bdd37182ba34a171b49e45f5976/podcasts_opml.xml" "robbieferrero-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/rouzbeh84/72d0b1d450216249b288b4460e7b470a/raw/8fdbf68a562b9943a197e414e3b1861ba43c84a6/podcasts.opml" "rouzbeh84-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/roytoo/eb8bd057385586b9cc30ce281a0c15f1/raw/f7b66a7ba9856af0add37eaea576a53b4928d8ca/RadioPublic.opml" "roytoo-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/russellbeattie/5545671/raw/b2efdf05ec993780e7583d4d105a4a167c5e682e/google_reader_bundle_subs.opml" "russellbeattie-rss.opml"
MirrorOPML "https://gist.githubusercontent.com/staxmanade/8365463/raw/9721d3fcdbe366bffe50e1498c254187c2ad40d1/Podcasts.opml" "staxmanade-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/tatsumoto-ren/1df342d5270680f3c9dca078a93298a4/raw/d885f6c2f6ba11076f1e7b5c930472925e050304/podcasts.opml" "tatsumoto-ren-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/tequreq/68352436e07207e2fda619b8088adc7f/raw/3507c7ee0f63cc61d1b43551863f22357fe49af1/ok.opml" "tequreq-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/thcipriani/80c4eba876b1fab1fd390919c2c84c5f/raw/158fde50f78b90c9b1598d1a24ee6ca53b8b0177/podcasts.opml" "thcipriani-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/thomasknoll/6f0f17e1ef72c0ead6fb/raw/f506afe769657a467b8791656fd5d035e1a08308/gistfile1.txt" "thomasknoll-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/whatrocks/916d0108280e2af24e56d174d51b7634/raw/b735763cebdb79ed2d267e4836e005954e4f7d20/podcast.opml" "whatrocks-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/x2q/5128073/raw/c99195b7f5895f5f86a2fcb11b8d0aa10d7ce9ff/netradio.opml" "x2q-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/yclian/2c6cf879ed8e1c285151ee6fc43362ab/raw/d73efad10d074460196b047e7be50c38b9391a32/overcast.opml" "yclian-podcasts.opml"
MirrorOPML "https://gist.githubusercontent.com/yorkxin/aa3439ce64de0e8d6d533de994196fff/raw/1cbd92a60ce9066abbdb2490d3c9c28548d0c7e0/Podcasts.opml" "yorkxin-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/alekseysidorov/zizulja/master/feeds01.opml" "alekseysidorov-zizulja-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Blake-/cyber-security-podcasts/main/cyber-security-podcasts.opml" "blake-cyber-security-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Cj-Malone/Linux-Podcasts/master/feeds.opml" "cj-malone-linux-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/corenominal/podcasts-opml/main/gnome-podcasts-exported-shows.opml" "corenominal-gnome-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/EngineeringKiosk/GermanTechPodcasts/main/podcasts.opml" "engineeringkiosk-germantechpodcasts-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/ianbarton/podcasts/master/podcasts_opml.xml" "ianbarton-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/JonZeolla/InfoSec-Starter-Kit/master/podcasts.opml" "jonzeolla-infosec-starter-kit-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Luke-Tech/news_sources/main/podcasts.opml" "luke-tech-news-sources-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/marklogic-community/feed/master/test-scripts/data/opml_podcast.opml" "marklogic-community-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Nogamara/blaugust-opml/master/output/blapril2020/blaugust.opml" "nogamara-blaugust-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/nurkiewicz/nurkiewicz.com/master/src/overcast.opml" "nurkiewicz-com-overcast-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/OpenScienceRadio/Open-Science-Radio-Shownotes/master/OSR021/Auszug_Wissenschaftspodcasts_MFR_2014-06-03.opml" "openscienceradio-20140603-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/podcast-data-lab/podcast-data-generator/main/data/podcasts_opml.xml" "podcast-data-lab-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/sonirico/podcastmanager/master/podcasts.opml" "sonirico-podcastmanager-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/sonirico/podcastmanager/master/podcasts_old_20160116.opml" "sonirico-podcastmanager-podcasts-old-20160116.opml"
MirrorOPML "https://raw.githubusercontent.com/sonirico/podcastmanager/master/Radio%20Podcast.opml" "sonirico-podcastmanager-radio-podcast.opml"
MirrorOPML "https://raw.githubusercontent.com/taext/powercasts/master/podcasts_opml.xml" "taext-powercasts-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/topgold/listening/master/fm.opml" "topgold-fm-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/truecrimereview/truecrimepodcasts/master/true_crime_podcasts.opml" "truecrimereview-true-crime-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/vinhnx/podcasts/master/overcast.opml" "vinhnx-podcasts-overcast.opml"
MirrorOPML "https://raw.githubusercontent.com/yasuharu519/opml/master/main.opml" "yasuhary519-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/zhufengme/Chinese-Podcasts/master/Podcasts.opml" "zhufengme-chinese-podcasts.opml"

MirrorOPML "https://podnews.net/opml/edison-top-50-podcasts-us-q225" "podnews-net-edison-top-50-podcasts-us-q225.opml"
MirrorOPML "https://podnews.net/opml/political-awards-2025" "podnews-net-political-awards-2025.opml"
MirrorOPML "https://podnews.net/opml/edison-podcast-metrics-q423-uk" "podnews-net-edison-podcast-metrics-q423-uk.opml"
MirrorOPML "https://podnews.net/opml/apple-podcasts-top-shows-2024" "podnews-net-apple-podcasts-top-shows-2024.opml"
MirrorOPML "https://podnews.net/opml/women-podcasters-awards" "podnews-net-wome-podcasters-awards-2025-winners.opml"
MirrorOPML "https://podnews.net/opml/the-podcast-salon-v1" "podnews-net-the-podcast-salon-v1.opml"
MirrorOPML "https://podnews.net/opml/publisher-podcast-awards-2025" "podnews-net-publisher-podcast-awards-2025.opml"
MirrorOPML "https://podnews.net/opml/podcast-radio-business" "podnews-net-podcast-radio-business.opml"
MirrorOPML "https://podnews.net/opml/webby-awards-2025-2" "podnews-net-webby-awards-2025.opml"
MirrorOPML "https://podnews.net/opml/apple-best-so-far-aug-2025" "podnews-net-apple-best-so-far-aug-2025.opml"
MirrorOPML "https://podnews.net/opml/british-podcast-awards" "podnews-net-british-podcast-awards.opml"
