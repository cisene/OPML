#!/usr/bin/env bash

function escapeURL {
  echo ""
}

function fetchToDisk {
  echo "Fetching $1 .."
  #wget --quiet -O "temp.opml" "$1"
  wget --quiet --tries=3 --timeout=10 --dns-timeout=5 --connect-timeout=5 --read-timeout=10 -O "temp.opml" "$1"
}

function delint {
  #rm "$1"
  #cat temp.opml | xmllint --recover --format - > "$1"
  cat temp.opml | xmllint --nonet --noent --recover --xmlout --format - > "$1"
}

function mirrorTimestamp {
  echo "$(date --utc --iso-8601=seconds)Z"
}

function removeTemp {
  rm temp.opml
}

function fixCharacters {
  #sed -i "s|\x26amp\x3b|\&amp;|gi" temp.opml
  #sed -i "s|\b\x26(?!(.+?)\x3b)\b|\&amp;|gi" temp.opml
  #sed -i "s|\s\x26\s| \&amp; |gi" temp.opml
  sed -i "s|\x22\x22|\"|gi" temp.opml
  sed -i "s/\x26(?!(?:apos|quot|[gl]t|amp)\x3b|#)/&amp;/gi" temp.opml
}

function addMirrorTag {
  TIMESTAMP="$(date --iso-8601=seconds)Z"

  # Attempt removal of XSL stylesheet
  # <?xml-stylesheet type="text/xsl" href="style.xsl"?>
  # <?xml-stylesheet type="text/xsl" href="style.xsl"?>
  sed -i "s|\x3c\x3fxml\x2dstylesheet\x20(.+?)\x3f\x3e|<!-- stylesheet removed -->|gi" "$2"
  sed -i "s|\x3c\x3fxml\x2dstylesheet\x20type\x3d\x22text\x2fxsl\x22\x20href\x3d\x22(.+?)\x2exsl\x22\x3f\x3e|<!-- stylesheet removed -->|gi" "$2"

  # OPML 1.0
  sed -i "s|\x3copml\x20version\x3d\x221\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"1.0\">|gi" "$2"

  # OPML 1.1
  sed -i "s|\x3copml\x20version\x3d\x221\x2e1\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"1.1\">|gi" "$2"

  # OPML 2.0
  sed -i "s|\x3copml\x20version\x3d\x222\x2e0\x22\x3e|<!-- Mirrored at ${TIMESTAMP} from $1 to https://b19.se/data/opml/mirrored/$2 -->\n<opml version=\"2.0\">|gi" "$2"

  sed -i "s|\s\x26\s| \&amp; |gi" "$2"


}

function MirrorOPML {
  echo "Mirroring '$1' to '$2' ..."
  fetchToDisk "$1"
  fixCharacters "$2"
  delint "$2"
  addMirrorTag "$1" "$2"
  removeTemp
}


# CBC Canada
MirrorOPML "http://www.cbc.ca/podcasts.opml" "cbc-ca-podcasts.opml"

# CNN
MirrorOPML "http://edition.cnn.com/services/podcasting/CNN.opml" "cnn-edition.opml"

# BBC
MirrorOPML "http://www.bbc.co.uk/podcasts.opml" "bbc-co-uk-podcasts.opml"
MirrorOPML "http://news.bbc.co.uk/rss/feeds.opml" "bbc-co-uk-news-rss-feeds.opml"

# Gigadial
MirrorOPML "http://www.gigadial.net/public/opml/" "gigadial-pod.opml"

# RTL France
MirrorOPML "https://www.rtl.fr/podcasts.opml" "rtl-fr-podcasts.opml"

# ApaPodcast.cz
MirrorOPML "https://www.apapodcast.cz/podcast.opml" "apapodcast-cz-podcast.opml"

# Aloha Podcast Network
MirrorOPML "http://www.alohapodcast.com/APN.opml" "alohapodcast-apn.opml"


# Fyyd
MirrorOPML "https://fyyd.de/user/altf4/collection/deutsch/opml" "fyyd-de-altf4-collection-deutsch.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/fotografiepodcasts/opml" "fyyd-de-dirkprimbs-collection-fotografiepodcasts.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/podcastpodcasts/opml" "fyyd-de-dirkprimbs-collection-podcastpodcasts.opml"
MirrorOPML "https://fyyd.de/user/emolotow/collection/f361eea6f2288b3b565324885c91290a/opml" "fyyd-de-emoltow-collection.opml"
MirrorOPML "https://fyyd.de/user/garneleh/collection/audiospass-fuer-kids-und-co/opml" "fyyd-de-garneleh-collection-audiospass-fuer-kids-und-co.opml"
MirrorOPML "https://fyyd.de/user/garneleh/collection/frauenstimmen-im-netz/opml" "fyyd-de-garneleh-collection-frauenstimmen-im-netz.opml"
MirrorOPML "https://fyyd.de/user/gglnx/collection/meine-podcasts/opml" "fyyd-de-gglnx-collection-meine-podcasts.opml"
MirrorOPML "https://fyyd.de/user/Graukaue/collection/oekonomie/opml" "fyyd-de-graukaue-collection-oekonomie.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/geschichte/opml" "fyyd-de-hoersuppe-collection-geschinchte.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/hoersuppe/opml" "fyyd-de-hoersuppe-collection-hoersuppe.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/holgis-podcasts/opml" "fyyd-de-hoersuppe-collection-holgis-podcasts.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasting/opml" "fyyd-de-hoersuppe-collection-podcasting.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasts-fuer-kinder/opml" "fyyd-de-hoersuppe-collection-podasts-fuer-kinder.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasts-high-noon/opml" "fyyd-de-hoersuppe-collection-podcasts-high-noon.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/utopia/opml" "fyyd-de-hoersuppe-collection-utopia.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/wmr-plugs/opml" "fyyd-de-hoersuppe-collection-wmr-plugs.opml"
MirrorOPML "https://fyyd.de/user/iwmm/collection/77c5dd6f7db4444989918a5726b90255/opml" "fyyd-de-iwmm-collection.opml"
MirrorOPML "https://fyyd.de/user/JaegersNet/collection/de-rpg-podcasts/opml" "fyyd-de-jaegersnet-collection-de-rpg-podcasts.opml"
MirrorOPML "https://fyyd.de/user/limpc0re/collection/a64e2c64ea98e27fa996effb1d44af0f/opml" "fyyd-de-limpc0re-collection.opml"
MirrorOPML "https://fyyd.de/user/ophmoph/collection/36c66142c31e4cd8edbe74c6b82b5483/opml" "fyyd-de-ophmoph-collection.opml"
MirrorOPML "https://fyyd.de/user/Podstock/collection/podstock2018/opml" "fyyd-de-podstock-collection-podstock2018.opml"
MirrorOPML "https://fyyd.de/user/rebel/collection/997f494a3a31d9885acd820499c0439a/opml" "fyyd-de-rebel-collecion.opml"
MirrorOPML "https://fyyd.de/user/Sliebschner/collection/comic-podcasts/opml" "fyyd-de-sliebschner-collection-comic-podcasts.opml"


# Pocketcasts
MirrorOPML "https://lists.pocketcasts.com/20under20.opml" "pocketcasts-com-20-under-20.opml"
MirrorOPML "https://lists.pocketcasts.com/abc.opml" "pocketcasts-com-abc.opml"
MirrorOPML "https://lists.pocketcasts.com/addressingracism.opml" "pocketcasts-com-addressing-racism.opml"
MirrorOPML "https://lists.pocketcasts.com/americanpublicmedia.opml" "pocketcasts-com-american-public-media.opml"
MirrorOPML "https://lists.pocketcasts.com/audiovisual.opml" "pocketcasts-com-audiovisual.opml"
MirrorOPML "https://lists.pocketcasts.com/australianabc.opml" "pocketcasts-com-australian-abc.opml"
MirrorOPML "https://lists.pocketcasts.com/best-of-2016.opml" "pocketcasts-com-best-of-2016.opml"
MirrorOPML "https://lists.pocketcasts.com/best-of-2019.opml" "pocketcasts-com-best-of-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/betterbedtime.opml" "pocketcasts-com-better-bedtime.opml"
MirrorOPML "https://lists.pocketcasts.com/biopods.opml" "pocketcasts-com-biopods.opml"
MirrorOPML "https://lists.pocketcasts.com/carolinecrampton.opml" "pocketcasts-com-caroline-crampton.opml"
MirrorOPML "https://lists.pocketcasts.com/catpockets.opml" "pocketcasts-com-catpockets.opml"
MirrorOPML "https://lists.pocketcasts.com/cbc.opml" "pocketcasts-com-cbc.opml"
MirrorOPML "https://lists.pocketcasts.com/celebratingblackhistorymonth.opml" "pocketcasts-com-celebrating-black-history-month.opml"
MirrorOPML "https://lists.pocketcasts.com/coronavirus.opml" "pocketcasts-com-coronavirus.opml"
MirrorOPML "https://lists.pocketcasts.com/crimetime.opml" "pocketcasts-com-crime-time.opml"
MirrorOPML "https://lists.pocketcasts.com/curtco.opml" "pocketcasts-com-curtco.opml"
MirrorOPML "https://lists.pocketcasts.com/dontboo.opml" "pocketcasts-com-dont-boo.opml"
MirrorOPML "https://lists.pocketcasts.com/eariefiction.opml" "pocketcasts-com-earie-fiction.opml"
MirrorOPML "https://lists.pocketcasts.com/earthday.opml" "pocketcasts-com-earthday.opml"
MirrorOPML "https://lists.pocketcasts.com/earwolf.opml" "pocketcasts-com-earwolf.opml"
MirrorOPML "https://lists.pocketcasts.com/eone.opml" "pocketcasts-com-eone.opml"
MirrorOPML "https://lists.pocketcasts.com/featured.opml" "pocketcasts-com-featured.opml"
MirrorOPML "https://lists.pocketcasts.com/femalefocused.opml" "pocketcasts-com-female-focused.opml"
MirrorOPML "https://lists.pocketcasts.com/foreverdog.opml" "pocketcasts-com-foreverdog.opml"
MirrorOPML "https://lists.pocketcasts.com/forthekids.opml" "pocketcasts-com-for-the-kids.opml"
MirrorOPML "https://lists.pocketcasts.com/frequency.opml" "pocketcasts-com-frequency.opml"
MirrorOPML "https://lists.pocketcasts.com/ftb-lgbtq.opml" "pocketcasts-com-ftb-lgbtq.opml"
MirrorOPML "https://lists.pocketcasts.com/gamenight.opml" "pocketcasts-com-gamenight.opml"
MirrorOPML "https://lists.pocketcasts.com/ghoulishtales.opml" "pocketcasts-com-ghoulish-tales.opml"
MirrorOPML "https://lists.pocketcasts.com/gottolisten.opml" "pocketcasts-com-got-to-listen.opml"
MirrorOPML "https://lists.pocketcasts.com/guiltypleasures.opml" "pocketcasts-com-guilty-pleasures.opml"
MirrorOPML "https://lists.pocketcasts.com/havealaugh.opml" "pocketcasts-com-have-a-laugh.opml"
MirrorOPML "https://lists.pocketcasts.com/headgum.opml" "pocketcasts-com-headgum.opml"
MirrorOPML "https://lists.pocketcasts.com/holidaysurvivalguide.opml" "pocketcasts-com-holiday-survival-guide.opml"
MirrorOPML "https://lists.pocketcasts.com/jameskim.opml" "pocketcasts-com-james-kim.opml"
MirrorOPML "https://lists.pocketcasts.com/keepplaying.opml" "pocketcasts-com-keep-playing.opml"
MirrorOPML "https://lists.pocketcasts.com/laurenober.opml" "pocketcasts-com-lauren-ober.opml"
MirrorOPML "https://lists.pocketcasts.com/laurenspohrer.opml" "pocketcasts-com-lauren-spohrer.opml"
MirrorOPML "https://lists.pocketcasts.com/lgbtqueue.opml" "pocketcasts-com-lgbt-queue.opml"
MirrorOPML "https://lists.pocketcasts.com/lippmedia.opml" "pocketcasts-com-lipp-media.opml"
MirrorOPML "https://lists.pocketcasts.com/listenersbeware.opml" "pocketcasts-com-listeners-beware.opml"
MirrorOPML "https://lists.pocketcasts.com/lookingback.opml" "pocketcasts-com-looking-back.opml"
MirrorOPML "https://lists.pocketcasts.com/marquesbrownlee.opml" "pocketcasts-com-marques-brown-lee.opml"
MirrorOPML "https://lists.pocketcasts.com/mattgourley.opml" "pocketcasts-com-matt-gourley.opml"
MirrorOPML "https://lists.pocketcasts.com/maxfun.opml" "pocketcasts-com-maxfun.opml"
MirrorOPML "https://lists.pocketcasts.com/maximumfun.opml" "pocketcasts-com-maximum-fun.opml"
MirrorOPML "https://lists.pocketcasts.com/mealtime.opml" "pocketcasts-com-mealtime.opml"
MirrorOPML "https://lists.pocketcasts.com/mixtapes.opml" "pocketcasts-com-mixtapes.opml"
MirrorOPML "https://lists.pocketcasts.com/peterwells.opml" "pocketcasts-com-peter-wells.opml"
MirrorOPML "https://lists.pocketcasts.com/popular.opml" "pocketcasts-com-popular.opml"
MirrorOPML "https://lists.pocketcasts.com/pushkin.opml" "pocketcasts-com-pushkin.opml"
MirrorOPML "https://lists.pocketcasts.com/radiotopia.opml" "pocketcasts-com-radiotopia.opml"
MirrorOPML "https://lists.pocketcasts.com/rashikarao.opml" "pocketcasts-com-rashikarao.opml"
MirrorOPML "https://lists.pocketcasts.com/romance.opml" "pocketcasts-com-romance.opml"
MirrorOPML "https://lists.pocketcasts.com/scarscrabble.opml" "pocketcasts-com-scarscrabble.opml"
MirrorOPML "https://lists.pocketcasts.com/scarypods.opml" "pocketcasts-com-scary-pods.opml"
MirrorOPML "https://lists.pocketcasts.com/showmethemoney.opml" "pocketcasts-com-show-me-the-money.opml"
MirrorOPML "https://lists.pocketcasts.com/socialdistancing.opml" "pocketcasts-com-social-distancing.opml"
MirrorOPML "https://lists.pocketcasts.com/sonypodcasts.opml" "pocketcasts-com-sony-podcasts.opml"
MirrorOPML "https://lists.pocketcasts.com/spokemedia.opml" "pocketcasts-com-spoke-media.opml"
MirrorOPML "https://lists.pocketcasts.com/stayresolute.opml" "pocketcasts-com-stay-resolute.opml"
MirrorOPML "https://lists.pocketcasts.com/talkies.opml" "pocketcasts-com-talkies.opml"
MirrorOPML "https://lists.pocketcasts.com/thepodglomerate.opml" "pocketcasts-com-the-podglomerate.opml"
MirrorOPML "https://lists.pocketcasts.com/top-100-of-2020.opml" "pocketcasts-com-top-100-of-2020.opml"
MirrorOPML "https://lists.pocketcasts.com/top-100-of-2021.opml" "pocketcasts-com-top-100-of-2021.opml"
MirrorOPML "https://lists.pocketcasts.com/top-australia-2019.opml" "pocketcasts-com-top-australia-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2019.opml" "pocketcasts-com-top-podcasts-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2020.opml" "pocketcasts-com-top-podcasts-2020.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2021.opml" "pocketcasts-com-top-podcasts-2021.opml"
MirrorOPML "https://lists.pocketcasts.com/top-united-kingdom-2019.opml" "pocketcasts-com-top-united-kingdom-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/trending.opml" "pocketcasts-com-trending.opml"
MirrorOPML "https://lists.pocketcasts.com/truecrimeandlime.opml" "pocketcasts-com-truecrime-and-lime.opml"
MirrorOPML "https://lists.pocketcasts.com/twit.opml" "pocketcasts-com-twit.opml"
MirrorOPML "https://lists.pocketcasts.com/vox.opml" "pocketcasts-com-vox.opml"
MirrorOPML "https://lists.pocketcasts.com/whatsnext.opml" "pocketcasts-com-whats-next.opml"

# DigitalPodcast
MirrorOPML "http://www.digitalpodcast.com/opml/digitalpodcast.opml" "digitalpodcast-com-directory.opml"
MirrorOPML "http://www.digitalpodcast.com/opml/digitalpodcastnew.opml" "digitalpodcast-com-50-newest.opml"
MirrorOPML "http://www.digitalpodcast.com/opml/digitalpodcastmostviewed.opml" "digitalpodcast-com-50-top-visits.opml"
MirrorOPML "http://www.digitalpodcast.com/opml/digitalpodcasttoprated.opml" "digitalpodcast-com-50-top-rated.opml"
MirrorOPML "http://www.digitalpodcast.com/opml/digitalpodcastmostsubscribed.opml" "digitalpodcast-com-50-most-subscribed.opml"

# TWiT.tv
MirrorOPML "https://feeds.twit.tv/twitfeeds.opml" "twit-tv-twitfeeds.opml"
MirrorOPML "https://feeds.twit.tv/twitshows.opml" "twit-tv-twitshows.opml"
MirrorOPML "https://feeds.twit.tv/twitshows_video_hd.opml" "twit-tv-twitshows-video-hd.opml"

# IOSDevDirectory
MirrorOPML "https://iosdevdirectory.com/opml/en/podcasts.opml" "iosdevdirectory-english-podcasts.opml"
MirrorOPML "https://iosdevdirectory.com/opml/es/podcasts.opml" "iosdevdirectory-spanish-podcasts.opml"
MirrorOPML "https://iosdevdirectory.com/opml/de/podcasts.opml" "iosdevdirectory-german-podcasts.opml"

# iPodder Sourceforge
MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder-aegrumet.opml" "ipodder-sourceforge-net-ipodder-aegrumet.opml"
MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder-gtk.opml" "ipodder-sourceforge-net-ipodder-gtk.opml"
MirrorOPML "http://ipodder.sourceforge.net/opml/ipodder.opml" "ipodder-sourceforge-net-ipodder.opml"

# Radio2
MirrorOPML "http://s3.amazonaws.com/radio2/communityReadingList.opml" "radio2-communityReadingList.opml"

# Divergence-Fm
MirrorOPML "http://podcasts.divergence-fm.org/podcasts.opml" "divergence-fm-podcasts.opml"


# Misc
# MirrorOPML "http://drummer.scripting.com/AndySylvester99/FavoritePodcasts.opml" "andysylvester99-favoriepodcasts.opml"
# MirrorOPML "http://www.mit.edu/~gsstark/miro.opml" "gsstark-miro.opml"
MirrorOPML "http://media.phlow.de/download/rss/podcast.opml" "phlow-de-podcasts.opml"
MirrorOPML "http://rasterweb.net/raster/feeds/wisconsin.opml" "rasterweb-net-wisconsin.opml"
MirrorOPML "http://rss.sina.com.cn/sina_all_opml.xml" "sina-com-cn-all.opml"
MirrorOPML "http://www.electricsky.net/radio.opml" "electricsky-net-radio.opml"
MirrorOPML "http://www.marshallk.com/politicalaudio.aspx.xml" "marshalls-politicalaudio.opml"
MirrorOPML "https://ainali.com/listening/feed.opml" "ainali-listening.opml"
MirrorOPML "https://dave.sobr.org/enc/1662343807.433_polishpodcastdirectoryopml.xml" "podkasty-info-katalog-podkastow.opml"
MirrorOPML "https://defaria.com/podcasts.opml" "defaria-podcasts.opml"
MirrorOPML "https://dhruv-sharma.ovh/files/podcasts.opml" "dhruv-sharma.opml"
MirrorOPML "https://digiper.com/dl/digiper.opml" "digiper.opml"
MirrorOPML "https://inkdroid.org/podcasts/feed.opml" "inkdroid-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Cj-Malone/Linux-Podcasts/master/feeds.opml" "cj-malone-linux-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/yasuharu519/opml/master/main.opml" "yasuhary519.opml"
MirrorOPML "https://source.mcwhirter.io/craige/rcfiles/raw/branch/consensus/.gpodder.opml" "mcwhirter-craige-consensus-gpodder.opml"
MirrorOPML "https://typlog.com/podlist/opml.xml" "typlog-pod.opml"
MirrorOPML "https://welcometochina.com.au/wp-content/uploads/china-podcasts.opml" "welcomtochina-china-podcasts.opml"
MirrorOPML "https://wissenschaftspodcasts.de/opml-export/" "wissenschafts-podcasts.opml"
MirrorOPML "https://www.ancientfaith.com/feeds/podcasts.opml" "ancientfaith-podcasts.opml"
