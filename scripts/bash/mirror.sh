#!/usr/bin/env bash

function fetchToDisk {
  #echo "Fetching $1 .."
  wget --quiet --tries=3 --timeout=10 --dns-timeout=5 --connect-timeout=5 --read-timeout=10 -O "temp.opml" "$1"
}

function delint {
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
  set -i "s|\s{2,}| |gi" temp.opml

  set -i "s|\x26amp\x3bndash\x3b|\&ndash;|gi" temp.opml
  #sed -i "s|\x26amp\x3b|\&amp;|gi" temp.opml
  #sed -i "s|\b\x26(?!(.+?)\x3b)\b|\&amp;|gi" temp.opml
  #sed -i "s|\s\x26\s| \&amp; |gi" temp.opml
  sed -i "s|\x22\x22|\"|gi" temp.opml
  sed -i "s/\x26(?!(?:apos|quot|[gl]t|amp)\x3b|#)/&amp;/gi" temp.opml

  sed -i "s|\x27|\&apos;|gi" temp.opml
  set -i "s|\x26\x2339\x3b|\&apos;|gi" temp.opml

  sed -i "s|\s\x26\s| \&amp; |gi" temp.opml
}

function fixXML {
  # Remove empty htmlUrl attributes
  sed -i "s|\s{1,}htmlUrl\x3d\x22\x22| htmlUrl=\"https://podcastindex.org/\"|gi" temp.opml
  set -i "s|\stext\x3d\x22\x22| text=\"Podcast\"|gi" temp.opml

  sed -i "s|\x3copml\sversion\x3d\x271.0\x27\x3e<opml version='1.0'>|<opml version=\"1.0\">|gi" temp.opml
  sed -i "s|\x3copml\sversion\x3d\x271.2\x27\x3e<opml version='1.0'>|<opml version=\"1.0\">|gi" temp.opml
  sed -i "s|\x3copml\sversion\x3d\x272.1\x27\x3e<opml version='1.0'>|<opml version=\"2.0\">|gi" temp.opml

  # Remove empty description attribute
  sed -i "s|\sdescription\x3d\x22\x22||gi" temp.opml

  # Attempt removal of XSL stylesheet
  # <?xml-stylesheet type="text/xsl" href="style.xsl"?>
  # <?xml-stylesheet type="text/xsl" href="style.xsl"?>
  sed -i "s|\x3c\x3fxml\x2dstylesheet\s(.+?)\x3f\x3e|<!-- stylesheet removed -->|gi" "$2"
  sed -i "s|\x3c\x3f(\s+)?xml\x2dstylesheet\x20type\x3d\x22text\x2fxsl\x22\x20href\x3d\x22(.+?)\x2exsl\x22(\s+)?\x3f\x3e|<!-- stylesheet removed -->|gi" "$2"

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
  echo "Mirroring '$1' to '$2' ..."
  fetchToDisk "$1"
  fixXML "$2"
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

# IBM
MirrorOPML "https://www.ibm.com/ibm/syndication/podcasts/us/en/index.opml" "ibm-podcasts.opml"


# Fyyd
MirrorOPML "https://fyyd.de/user/altf4/collection/deutsch/opml" "fyyd-de-altf4-collection-deutsch.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/fotografiepodcasts/opml" "fyyd-de-dirkprimbs-collection-fotografiepodcasts.opml"
MirrorOPML "https://fyyd.de/user/dirkprimbs/collection/podcastpodcasts/opml" "fyyd-de-dirkprimbs-collection-podcastpodcasts.opml"
MirrorOPML "https://fyyd.de/user/emolotow/collection/f361eea6f2288b3b565324885c91290a/opml" "fyyd-de-emoltow-collection.opml"
MirrorOPML "https://fyyd.de/user/garneleh/collection/audiospass-fuer-kids-und-co/opml" "fyyd-de-garneleh-collection-audiospass-fuer-kids-und-co.opml"
MirrorOPML "https://fyyd.de/user/garneleh/collection/frauenstimmen-im-netz/opml" "fyyd-de-garneleh-collection-frauenstimmen-im-netz.opml"
MirrorOPML "https://fyyd.de/user/gglnx/collection/meine-podcasts/opml" "fyyd-de-gglnx-collection-meine-podcasts.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/geschichte/opml" "fyyd-de-hoersuppe-collection-geschinchte.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/hoersuppe/opml" "fyyd-de-hoersuppe-collection-hoersuppe.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/holgis-podcasts/opml" "fyyd-de-hoersuppe-collection-holgis-podcasts.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasting/opml" "fyyd-de-hoersuppe-collection-podcasting.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasts-fuer-kinder/opml" "fyyd-de-hoersuppe-collection-podasts-fuer-kinder.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/podcasts-high-noon/opml" "fyyd-de-hoersuppe-collection-podcasts-high-noon.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/utopia/opml" "fyyd-de-hoersuppe-collection-utopia.opml"
MirrorOPML "https://fyyd.de/user/hoersuppe/collection/wmr-plugs/opml" "fyyd-de-hoersuppe-collection-wmr-plugs.opml"
MirrorOPML "https://fyyd.de/user/holgi/collection/holgi/opml" "fyyd-de-holgi-collection-holgi.opml"
MirrorOPML "https://fyyd.de/user/iwmm/collection/77c5dd6f7db4444989918a5726b90255/opml" "fyyd-de-iwmm-collection.opml"
MirrorOPML "https://fyyd.de/user/JaegersNet/collection/de-rpg-podcasts/opml" "fyyd-de-jaegersnet-collection-de-rpg-podcasts.opml"
MirrorOPML "https://fyyd.de/user/limpc0re/collection/a64e2c64ea98e27fa996effb1d44af0f/opml" "fyyd-de-limpc0re-collection.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/32dc7ac001dadd43706168d80024d7bb/opml" "fyyd-de-misterl-collection-filme-serien.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/6bb99465e345d025c4ffe8b8bd5f8ff6/opml" "fyyd-de-misterl-collection-albernes.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/8303a30eaffb78e30781753fa08fc769/opml" "fyyd-de-misterl-collection-it.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/9e39ab6ee95f5f4ba8b0c3368cd1828c/opml" "fyyd-de-misterl-collection-politik.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/c50796e5a93ed2db202a6315780dc548/opml" "fyyd-de-misterl-collection-jura.opml"
MirrorOPML "https://fyyd.de/user/MisterL/collection/cae73c22ce49638a4b57b5a6eac2420d/opml" "fyyd-de-misterl-collection-belletristik.opml"
MirrorOPML "https://fyyd.de/user/ophmoph/collection/36c66142c31e4cd8edbe74c6b82b5483/opml" "fyyd-de-ophmoph-collection.opml"
MirrorOPML "https://fyyd.de/user/Podstock/collection/podstock2018/opml" "fyyd-de-podstock-collection-podstock2018.opml"
MirrorOPML "https://fyyd.de/user/rebel/collection/997f494a3a31d9885acd820499c0439a/opml" "fyyd-de-rebel-collecion.opml"
MirrorOPML "https://fyyd.de/user/Sliebschner/collection/comic-podcasts/opml" "fyyd-de-sliebschner-collection-comic-podcasts.opml"

# Pocketcasts
MirrorOPML "https://lists.pocketcasts.com/20-under-20.opml" "pocketcasts-com-20-under-20.opml"
MirrorOPML "https://lists.pocketcasts.com/20under20.opml" "pocketcasts-com-20-under-20.opml"
MirrorOPML "https://lists.pocketcasts.com/abc.opml" "pocketcasts-com-abc.opml"
MirrorOPML "https://lists.pocketcasts.com/addressingracism.opml" "pocketcasts-com-addressing-racism.opml"
MirrorOPML "https://lists.pocketcasts.com/americanpublicmedia.opml" "pocketcasts-com-american-public-media.opml"
MirrorOPML "https://lists.pocketcasts.com/audiovisual.opml" "pocketcasts-com-audiovisual.opml"
MirrorOPML "https://lists.pocketcasts.com/australianabc.opml" "pocketcasts-com-australian-abc.opml"
MirrorOPML "https://lists.pocketcasts.com/bbc.opml" "pocketcasts-com-bbc.opml"
MirrorOPML "https://lists.pocketcasts.com/beachreads.opml" "pocketcasts-com-beachreads.opml"
MirrorOPML "https://lists.pocketcasts.com/best-of-2016.opml" "pocketcasts-com-best-of-2016.opml"
MirrorOPML "https://lists.pocketcasts.com/best-of-2019.opml" "pocketcasts-com-best-of-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/betterbedtime.opml" "pocketcasts-com-better-bedtime.opml"
MirrorOPML "https://lists.pocketcasts.com/biopods.opml" "pocketcasts-com-biopods.opml"
MirrorOPML "https://lists.pocketcasts.com/bridgettodd.opml" "pocketcasts-com-bridgettodd.opml"
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
MirrorOPML "https://lists.pocketcasts.com/earwolf-2022.opml" "pocketcasts-com-earwolf-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/earwolf.opml" "pocketcasts-com-earwolf.opml"
MirrorOPML "https://lists.pocketcasts.com/eone.opml" "pocketcasts-com-eone.opml"
MirrorOPML "https://lists.pocketcasts.com/featured.opml" "pocketcasts-com-featured.opml"
MirrorOPML "https://lists.pocketcasts.com/femalefocused.opml" "pocketcasts-com-female-focused.opml"
MirrorOPML "https://lists.pocketcasts.com/financial-times-2022.opml" "pocketcasts-com-financial-times-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/foreverdog.opml" "pocketcasts-com-foreverdog.opml"
MirrorOPML "https://lists.pocketcasts.com/forthekids.opml" "pocketcasts-com-for-the-kids.opml"
MirrorOPML "https://lists.pocketcasts.com/frequency.opml" "pocketcasts-com-frequency.opml"
MirrorOPML "https://lists.pocketcasts.com/ftb-lgbtq.opml" "pocketcasts-com-ftb-lgbtq.opml"
MirrorOPML "https://lists.pocketcasts.com/gamenight.opml" "pocketcasts-com-gamenight.opml"
MirrorOPML "https://lists.pocketcasts.com/ghoulishtales.opml" "pocketcasts-com-ghoulish-tales.opml"
MirrorOPML "https://lists.pocketcasts.com/gottolisten.opml" "pocketcasts-com-got-to-listen.opml"
MirrorOPML "https://lists.pocketcasts.com/guiltypleasures.opml" "pocketcasts-com-guilty-pleasures.opml"
MirrorOPML "https://lists.pocketcasts.com/happy-halloween-2022.opml" "pocketcasts-com-happy-halloween-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/havealaugh.opml" "pocketcasts-com-have-a-laugh.opml"
MirrorOPML "https://lists.pocketcasts.com/headgum.opml" "pocketcasts-com-headgum.opml"
MirrorOPML "https://lists.pocketcasts.com/hitpoints.opml" "pocketcasts-com-hitpoints.opml"
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
MirrorOPML "https://lists.pocketcasts.com/mentalhealth.opml" "pocketcasts-com-mentalhealth.opml"
MirrorOPML "https://lists.pocketcasts.com/mixtapes.opml" "pocketcasts-com-mixtapes.opml"
MirrorOPML "https://lists.pocketcasts.com/neverendingqueue.opml" "pocketcasts-com-neverendingqueue.opml"
MirrorOPML "https://lists.pocketcasts.com/peterwells.opml" "pocketcasts-com-peter-wells.opml"
MirrorOPML "https://lists.pocketcasts.com/popcornandpodcasts.opml" "pocketcasts-com-popcornandpodcasts.opml"
MirrorOPML "https://lists.pocketcasts.com/popular.opml" "pocketcasts-com-popular.opml"
MirrorOPML "https://lists.pocketcasts.com/pushkin.opml" "pocketcasts-com-pushkin.opml"
MirrorOPML "https://lists.pocketcasts.com/radiotopia.opml" "pocketcasts-com-radiotopia.opml"
MirrorOPML "https://lists.pocketcasts.com/rashikarao.opml" "pocketcasts-com-rashikarao.opml"
MirrorOPML "https://lists.pocketcasts.com/romance.opml" "pocketcasts-com-romance.opml"
MirrorOPML "https://lists.pocketcasts.com/scarscrabble.opml" "pocketcasts-com-scarscrabble.opml"
MirrorOPML "https://lists.pocketcasts.com/scarypods.opml" "pocketcasts-com-scary-pods.opml"
MirrorOPML "https://lists.pocketcasts.com/showmethemoney.opml" "pocketcasts-com-show-me-the-money.opml"
MirrorOPML "https://lists.pocketcasts.com/socialdistancing.opml" "pocketcasts-com-social-distancing.opml"
MirrorOPML "https://lists.pocketcasts.com/sony-music-entertainment-2022.opml" "pocketcasts-com-sony-music-entertainment-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/sonypodcasts.opml" "pocketcasts-com-sony-podcasts.opml"
MirrorOPML "https://lists.pocketcasts.com/spokemedia.opml" "pocketcasts-com-spoke-media.opml"
MirrorOPML "https://lists.pocketcasts.com/stayresolute.opml" "pocketcasts-com-stay-resolute.opml"
MirrorOPML "https://lists.pocketcasts.com/talkies.opml" "pocketcasts-com-talkies.opml"
MirrorOPML "https://lists.pocketcasts.com/the-wnet-group-2022.opml" "pocketcasts-com-the-wnet-group-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/thepodglomerate.opml" "pocketcasts-com-the-podglomerate.opml"
MirrorOPML "https://lists.pocketcasts.com/thereplyallmazdatests.opml" "pocketcasts-com-thereplyallmazdatests.opml"
MirrorOPML "https://lists.pocketcasts.com/top-100-of-2020.opml" "pocketcasts-com-top-100-of-2020.opml"
MirrorOPML "https://lists.pocketcasts.com/top-100-of-2021.opml" "pocketcasts-com-top-100-of-2021.opml"
MirrorOPML "https://lists.pocketcasts.com/top-100-of-2022.opml" "pocketcasts-com-top-100-of-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/top-australia-2019.opml" "pocketcasts-com-top-australia-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/top-australia-2020.opml" "pocketcasts-com-top-australia-2020.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2019.opml" "pocketcasts-com-top-podcasts-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2020.opml" "pocketcasts-com-top-podcasts-2020.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2021.opml" "pocketcasts-com-top-podcasts-2021.opml"
MirrorOPML "https://lists.pocketcasts.com/top-podcasts-2022.opml" "pocketcasts-com-top-podcasts-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/top-united-kingdom-2019.opml" "pocketcasts-com-top-united-kingdom-2019.opml"
MirrorOPML "https://lists.pocketcasts.com/trannaandthomas.opml" "pocketcasts-com-trannaandthomas.opml"
MirrorOPML "https://lists.pocketcasts.com/trending.opml" "pocketcasts-com-trending.opml"
MirrorOPML "https://lists.pocketcasts.com/truecrimeandlime.opml" "pocketcasts-com-truecrime-and-lime.opml"
MirrorOPML "https://lists.pocketcasts.com/twit.opml" "pocketcasts-com-twit.opml"
MirrorOPML "https://lists.pocketcasts.com/vox.opml" "pocketcasts-com-vox.opml"
MirrorOPML "https://lists.pocketcasts.com/whatsnext.opml" "pocketcasts-com-whats-next.opml"
MirrorOPML "https://lists.pocketcasts.com/women-on-wickedness.opml" "pocketcasts-com-women-on-wickedness.opml"

MirrorOPML "https://lists.pocketcasts.com/hbs-podcast-network-2022.opml" "pocketcasts-com-hbs-podcast-network-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/arielle-nissenblatt.opml" "pocketcasts-com-arielle-nissenblatt.opml"
MirrorOPML "https://lists.pocketcasts.com/ai-revolution.opml" "pocketcasts-com-ai-revolution.opml"
MirrorOPML "https://lists.pocketcasts.com/message-heard-2023.opml" "pocketcasts-com-message-heard-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/environment-day-2023.opml" "pocketcasts-com-world-environment-day-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/next-chapter-podcasts-2023.opml" "pocketcasts-com-next-chapter-podcasts-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/fable-and-folly-2023.opml" "pocketcasts-com-fable-and-folley-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/bloody-fm-2023.opml" "pocketcasts-com-bloody-fm-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/cbc-podcasts-2023.opml" "pocketcasts-com-cbc-podcasts-2023.opml"
MirrorOPML "https://lists.pocketcasts.com/the-last-of-us.opml" "pocketcasts-com-the-last-of-us.opml"
MirrorOPML "https://lists.pocketcasts.com/soundbody.opml" "pocketcasts-com-soundbody.opml"
MirrorOPML "https://lists.pocketcasts.com/seasonal-spotlight.opml" "pocketcasts-com-seasonal-spotlight.opml"
MirrorOPML "https://lists.pocketcasts.com/learn-on-the-go.opml" "pocketcasts-com-learn-on-the-go.opml"
MirrorOPML "https://lists.pocketcasts.com/wondermedianetwork.opml" "pocketcasts-com-wonder-media-network.opml"
MirrorOPML "https://lists.pocketcasts.com/thepodglomerate.opml" "pocketcasts-com-the-podglomerate.opml"
MirrorOPML "https://lists.pocketcasts.com/criticalfrequency.opml" "pocketcasts-com-critical-frequency.opml"
MirrorOPML "https://lists.pocketcasts.com/eariefiction.opml" "pocketcasts-com-earie-fiction.opml"
MirrorOPML "https://lists.pocketcasts.com/imperativeentertainment.opml" "pocketcasts-com-imperative-entertainment.opml"
MirrorOPML "https://lists.pocketcasts.com/divestudios.opml" "pocketcasts-com-dive-studios.opml"
MirrorOPML "https://lists.pocketcasts.com/hair-raising-tales.opml" "pocketcasts-com-hair-raising-tales.opml"
MirrorOPML "https://lists.pocketcasts.com/qcode.opml" "pocketcasts-com-qcode.opml"
MirrorOPML "https://lists.pocketcasts.com/c13originals-2022.opml" "pocketcasts-com-c13-originals-2022.opml"
MirrorOPML "https://lists.pocketcasts.com/may-the-4th.opml" "pocketcasts-com-may-the-4th.opml"

# Player.fm
MirrorOPML "https://player.fm/en/featured/acoustic.opml" "player-fm-en-featured-acoustic.opml"
MirrorOPML "https://player.fm/en/featured/activism.opml" "player-fm-en-featured-activism.opml"
MirrorOPML "https://player.fm/en/featured/addiction.opml" "player-fm-en-featured-addiction.opml"
MirrorOPML "https://player.fm/en/featured/aging.opml" "player-fm-en-featured-aging.opml"
MirrorOPML "https://player.fm/en/featured/alcoholism.opml" "player-fm-en-featured-alcoholism.opml"
MirrorOPML "https://player.fm/en/featured/alternative-health.opml" "player-fm-en-featured-alternative-health.opml"
MirrorOPML "https://player.fm/en/featured/alternative.opml" "player-fm-en-featured-alternative.opml"
MirrorOPML "https://player.fm/en/featured/american-football.opml" "player-fm-en-featured-american-football.opml"
MirrorOPML "https://player.fm/en/featured/americana.opml" "player-fm-en-featured-americana.opml"
MirrorOPML "https://player.fm/en/featured/animals-and-pets.opml" "player-fm-en-featured-animals-and-pets.opml"
MirrorOPML "https://player.fm/en/featured/archery.opml" "player-fm-en-featured-archery.opml"
MirrorOPML "https://player.fm/en/featured/artificial-intelligence.opml" "player-fm-en-featured-artificial-intelligence.opml"
MirrorOPML "https://player.fm/en/featured/arts.opml" "player-fm-en-featured-arts.opml"
MirrorOPML "https://player.fm/en/featured/asmr.opml" "player-fm-en-featured-asmr.opml"
MirrorOPML "https://player.fm/en/featured/audio-drama.opml" "player-fm-en-featured-audio-drama.opml"
MirrorOPML "https://player.fm/en/featured/audiobooks.opml" "player-fm-en-featured-audiobooks.opml"
MirrorOPML "https://player.fm/en/featured/aussie-rules.opml" "player-fm-en-featured-aussie-rules.opml"
MirrorOPML "https://player.fm/en/featured/baseball.opml" "player-fm-en-featured-baseball.opml"
MirrorOPML "https://player.fm/en/featured/basketball.opml" "player-fm-en-featured-basketball.opml"
MirrorOPML "https://player.fm/en/featured/bedtime-stories.opml" "player-fm-en-featured-bedtime-stories.opml"
MirrorOPML "https://player.fm/en/featured/billiards.opml" "player-fm-en-featured-billiards.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-audio-drama.opml" "player-fm-en-featured-binge-worthy-audio-drama.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-documentary.opml" "player-fm-en-featured-binge-worthy-documentary.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-fiction.opml" "player-fm-en-featured-binge-worthy-fiction.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-horror.opml" "player-fm-en-featured-binge-worthy-horror.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-sci-fi-fantasy.opml" "player-fm-en-featured-binge-worthy-sci-fi-fantasy.opml"
MirrorOPML "https://player.fm/en/featured/binge-worthy-true-crime.opml" "player-fm-en-featured-binge-worthy-true-crime.opml"
MirrorOPML "https://player.fm/en/featured/biohacking.opml" "player-fm-en-featured-biohacking.opml"
MirrorOPML "https://player.fm/en/featured/blues.opml" "player-fm-en-featured-blues.opml"
MirrorOPML "https://player.fm/en/featured/books-and-writing.opml" "player-fm-en-featured-books-and-writing.opml"
MirrorOPML "https://player.fm/en/featured/breaking-news.opml" "player-fm-en-featured-breaking-news.opml"
MirrorOPML "https://player.fm/en/featured/business-disciplines.opml" "player-fm-en-featured-business-disciplines.opml"
MirrorOPML "https://player.fm/en/featured/business-education.opml" "player-fm-en-featured-business-education.opml"
MirrorOPML "https://player.fm/en/featured/business-english.opml" "player-fm-en-featured-business-english.opml"
MirrorOPML "https://player.fm/en/featured/business-news.opml" "player-fm-en-featured-business-news.opml"
MirrorOPML "https://player.fm/en/featured/business.opml" "player-fm-en-featured-business.opml"
MirrorOPML "https://player.fm/en/featured/capitalism.opml" "player-fm-en-featured-capitalism.opml"
MirrorOPML "https://player.fm/en/featured/careers.opml" "player-fm-en-featured-careers.opml"
MirrorOPML "https://player.fm/en/featured/cinema.opml" "player-fm-en-featured-cinema.opml"
MirrorOPML "https://player.fm/en/featured/classical.opml" "player-fm-en-featured-classical.opml"
MirrorOPML "https://player.fm/en/featured/combat-sports.opml" "player-fm-en-featured-combat-sports.opml"
MirrorOPML "https://player.fm/en/featured/comedy.opml" "player-fm-en-featured-comedy.opml"
MirrorOPML "https://player.fm/en/featured/comics.opml" "player-fm-en-featured-comics.opml"
MirrorOPML "https://player.fm/en/featured/communities.opml" "player-fm-en-featured-communities.opml"
MirrorOPML "https://player.fm/en/featured/computer-science.opml" "player-fm-en-featured-computer-science.opml"
MirrorOPML "https://player.fm/en/featured/conspiracy-theories.opml" "player-fm-en-featured-conspiracy-theories.opml"
MirrorOPML "https://player.fm/en/featured/conversations.opml" "player-fm-en-featured-conversations.opml"
MirrorOPML "https://player.fm/en/featured/country.opml" "player-fm-en-featured-country.opml"
MirrorOPML "https://player.fm/en/featured/cricket.opml" "player-fm-en-featured-cricket.opml"
MirrorOPML "https://player.fm/en/featured/crowdfunding.opml" "player-fm-en-featured-crowdfunding.opml"
MirrorOPML "https://player.fm/en/featured/cryptocurrency.opml" "player-fm-en-featured-cryptocurrency.opml"
MirrorOPML "https://player.fm/en/featured/current-affairs.opml" "player-fm-en-featured-current-affairs.opml"
MirrorOPML "https://player.fm/en/featured/daily-news.opml" "player-fm-en-featured-daily-news.opml"
MirrorOPML "https://player.fm/en/featured/daily-tech-news.opml" "player-fm-en-featured-daily-tech-news.opml"
MirrorOPML "https://player.fm/en/featured/data-science.opml" "player-fm-en-featured-data-science.opml"
MirrorOPML "https://player.fm/en/featured/diabetes.opml" "player-fm-en-featured-diabetes.opml"
MirrorOPML "https://player.fm/en/featured/disability.opml" "player-fm-en-featured-disability.opml"
MirrorOPML "https://player.fm/en/featured/disc-golf.opml" "player-fm-en-featured-disc-golf.opml"
MirrorOPML "https://player.fm/en/featured/documentaries.opml" "player-fm-en-featured-documentaries.opml"
MirrorOPML "https://player.fm/en/featured/drum-and-bass.opml" "player-fm-en-featured-drum-and-bass.opml"
MirrorOPML "https://player.fm/en/featured/drumming.opml" "player-fm-en-featured-drumming.opml"
MirrorOPML "https://player.fm/en/featured/eclectic.opml" "player-fm-en-featured-eclectic.opml"
MirrorOPML "https://player.fm/en/featured/education.opml" "player-fm-en-featured-education.opml"
MirrorOPML "https://player.fm/en/featured/electronic.opml" "player-fm-en-featured-electronic.opml"
MirrorOPML "https://player.fm/en/featured/endurance-sports.opml" "player-fm-en-featured-endurance-sports.opml"
MirrorOPML "https://player.fm/en/featured/entertainment-industry.opml" "player-fm-en-featured-entertainment-industry.opml"
MirrorOPML "https://player.fm/en/featured/entertainment.opml" "player-fm-en-featured-entertainment.opml"
MirrorOPML "https://player.fm/en/featured/entrepreneur-lifestyle.opml" "player-fm-en-featured-entrepreneur-lifestyle.opml"
MirrorOPML "https://player.fm/en/featured/entrepreneur.opml" "player-fm-en-featured-entrepreneur.opml"
MirrorOPML "https://player.fm/en/featured/environment.opml" "player-fm-en-featured-environment.opml"
MirrorOPML "https://player.fm/en/featured/equestrian.opml" "player-fm-en-featured-equestrian.opml"
MirrorOPML "https://player.fm/en/featured/esports.opml" "player-fm-en-featured-esports.opml"
MirrorOPML "https://player.fm/en/featured/eurovision.opml" "player-fm-en-featured-eurovision.opml"
MirrorOPML "https://player.fm/en/featured/facts-and-trivia.opml" "player-fm-en-featured-facts-and-trivia.opml"
MirrorOPML "https://player.fm/en/featured/family.opml" "player-fm-en-featured-family.opml"
MirrorOPML "https://player.fm/en/featured/fantasy-sports.opml" "player-fm-en-featured-fantasy-sports.opml"
MirrorOPML "https://player.fm/en/featured/fascinating-people.opml" "player-fm-en-featured-fascinating-people.opml"
MirrorOPML "https://player.fm/en/featured/fashion-and-beauty.opml" "player-fm-en-featured-fashion-and-beauty.opml"
MirrorOPML "https://player.fm/en/featured/fintech.opml" "player-fm-en-featured-fintech.opml"
MirrorOPML "https://player.fm/en/featured/firefighting.opml" "player-fm-en-featured-firefighting.opml"
MirrorOPML "https://player.fm/en/featured/fitness.opml" "player-fm-en-featured-fitness.opml"
MirrorOPML "https://player.fm/en/featured/folk.opml" "player-fm-en-featured-folk.opml"
MirrorOPML "https://player.fm/en/featured/food-and-beverage.opml" "player-fm-en-featured-food-and-beverage.opml"
MirrorOPML "https://player.fm/en/featured/future-trends.opml" "player-fm-en-featured-future-trends.opml"
MirrorOPML "https://player.fm/en/featured/gaa.opml" "player-fm-en-featured-gaa.opml"
MirrorOPML "https://player.fm/en/featured/gadgets.opml" "player-fm-en-featured-gadgets.opml"
MirrorOPML "https://player.fm/en/featured/games-and-gambling.opml" "player-fm-en-featured-games-and-gambling.opml"
MirrorOPML "https://player.fm/en/featured/geekery.opml" "player-fm-en-featured-geekery.opml"
MirrorOPML "https://player.fm/en/featured/golf.opml" "player-fm-en-featured-golf.opml"
MirrorOPML "https://player.fm/en/featured/gospel-music.opml" "player-fm-en-featured-gospel-music.opml"
MirrorOPML "https://player.fm/en/featured/guitar.opml" "player-fm-en-featured-guitar.opml"
MirrorOPML "https://player.fm/en/featured/gymnastics.opml" "player-fm-en-featured-gymnastics.opml"
MirrorOPML "https://player.fm/en/featured/handball.opml" "player-fm-en-featured-handball.opml"
MirrorOPML "https://player.fm/en/featured/health-and-well-being.opml" "player-fm-en-featured-health-and-well-being.opml"
MirrorOPML "https://player.fm/en/featured/health-care.opml" "player-fm-en-featured-health-care.opml"
MirrorOPML "https://player.fm/en/featured/health-news.opml" "player-fm-en-featured-health-news.opml"
MirrorOPML "https://player.fm/en/featured/hiphop.opml" "player-fm-en-featured-hiphop.opml"
MirrorOPML "https://player.fm/en/featured/hobbies.opml" "player-fm-en-featured-hobbies.opml"
MirrorOPML "https://player.fm/en/featured/hockey.opml" "player-fm-en-featured-hockey.opml"
MirrorOPML "https://player.fm/en/featured/holidays.opml" "player-fm-en-featured-holidays.opml"
MirrorOPML "https://player.fm/en/featured/horror-stories.opml" "player-fm-en-featured-horror-stories.opml"
MirrorOPML "https://player.fm/en/featured/humanities-education.opml" "player-fm-en-featured-humanities-education.opml"
MirrorOPML "https://player.fm/en/featured/immigration.opml" "player-fm-en-featured-immigration.opml"
MirrorOPML "https://player.fm/en/featured/industries.opml" "player-fm-en-featured-industries.opml"
MirrorOPML "https://player.fm/en/featured/intellectual-dark-web.opml" "player-fm-en-featured-intellectual-dark-web.opml"
MirrorOPML "https://player.fm/en/featured/interior-design.opml" "player-fm-en-featured-interior-design.opml"
MirrorOPML "https://player.fm/en/featured/international-news.opml" "player-fm-en-featured-international-news.opml"
MirrorOPML "https://player.fm/en/featured/it-industry.opml" "player-fm-en-featured-it-industry.opml"
MirrorOPML "https://player.fm/en/featured/j-pop.opml" "player-fm-en-featured-j-pop.opml"
MirrorOPML "https://player.fm/en/featured/jazz.opml" "player-fm-en-featured-jazz.opml"
MirrorOPML "https://player.fm/en/featured/journalism.opml" "player-fm-en-featured-journalism.opml"
MirrorOPML "https://player.fm/en/featured/k-pop.opml" "player-fm-en-featured-k-pop.opml"
MirrorOPML "https://player.fm/en/featured/lacrosse.opml" "player-fm-en-featured-lacrosse.opml"
MirrorOPML "https://player.fm/en/featured/language-learning.opml" "player-fm-en-featured-language-learning.opml"
MirrorOPML "https://player.fm/en/featured/latin-music.opml" "player-fm-en-featured-latin-music.opml"
MirrorOPML "https://player.fm/en/featured/law-of-attraction.opml" "player-fm-en-featured-law-of-attraction.opml"
MirrorOPML "https://player.fm/en/featured/leadership.opml" "player-fm-en-featured-leadership.opml"
MirrorOPML "https://player.fm/en/featured/lifestyle.opml" "player-fm-en-featured-lifestyle.opml"
MirrorOPML "https://player.fm/en/featured/marketing.opml" "player-fm-en-featured-marketing.opml"
MirrorOPML "https://player.fm/en/featured/math.opml" "player-fm-en-featured-math.opml"
MirrorOPML "https://player.fm/en/featured/mba.opml" "player-fm-en-featured-mba.opml"
MirrorOPML "https://player.fm/en/featured/media.opml" "player-fm-en-featured-media.opml"
MirrorOPML "https://player.fm/en/featured/medicine.opml" "player-fm-en-featured-medicine.opml"
MirrorOPML "https://player.fm/en/featured/mens-corner.opml" "player-fm-en-featured-mens-corner.opml"
MirrorOPML "https://player.fm/en/featured/mens-health.opml" "player-fm-en-featured-mens-health.opml"
MirrorOPML "https://player.fm/en/featured/mental-health.opml" "player-fm-en-featured-mental-health.opml"
MirrorOPML "https://player.fm/en/featured/metal.opml" "player-fm-en-featured-metal.opml"
MirrorOPML "https://player.fm/en/featured/minimalist.opml" "player-fm-en-featured-minimalist.opml"
MirrorOPML "https://player.fm/en/featured/motorsports.opml" "player-fm-en-featured-motorsports.opml"
MirrorOPML "https://player.fm/en/featured/music-industry.opml" "player-fm-en-featured-music-industry.opml"
MirrorOPML "https://player.fm/en/featured/music.opml" "player-fm-en-featured-music.opml"
MirrorOPML "https://player.fm/en/featured/musicians.opml" "player-fm-en-featured-musicians.opml"
MirrorOPML "https://player.fm/en/featured/mythology.opml" "player-fm-en-featured-mythology.opml"
MirrorOPML "https://player.fm/en/featured/natural-sciences.opml" "player-fm-en-featured-natural-sciences.opml"
MirrorOPML "https://player.fm/en/featured/netflix.opml" "player-fm-en-featured-netflix.opml"
MirrorOPML "https://player.fm/en/featured/news-and-entertainment.opml" "player-fm-en-featured-news-and-entertainment.opml"
MirrorOPML "https://player.fm/en/featured/news-talk.opml" "player-fm-en-featured-news-talk.opml"
MirrorOPML "https://player.fm/en/featured/news.opml" "player-fm-en-featured-news.opml"
MirrorOPML "https://player.fm/en/featured/nutrition.opml" "player-fm-en-featured-nutrition.opml"
MirrorOPML "https://player.fm/en/featured/occupational-therapy.opml" "player-fm-en-featured-occupational-therapy.opml"
MirrorOPML "https://player.fm/en/featured/oldies.opml" "player-fm-en-featured-oldies.opml"
MirrorOPML "https://player.fm/en/featured/operating-systems.opml" "player-fm-en-featured-operating-systems.opml"
MirrorOPML "https://player.fm/en/featured/paranormal.opml" "player-fm-en-featured-paranormal.opml"
MirrorOPML "https://player.fm/en/featured/personal-finances.opml" "player-fm-en-featured-personal-finances.opml"
MirrorOPML "https://player.fm/en/featured/piano.opml" "player-fm-en-featured-piano.opml"
MirrorOPML "https://player.fm/en/featured/politics.opml" "player-fm-en-featured-politics.opml"
MirrorOPML "https://player.fm/en/featured/pop-culture.opml" "player-fm-en-featured-pop-culture.opml"
MirrorOPML "https://player.fm/en/featured/pop.opml" "player-fm-en-featured-pop.opml"
MirrorOPML "https://player.fm/en/featured/pregnancy.opml" "player-fm-en-featured-pregnancy.opml"
MirrorOPML "https://player.fm/en/featured/prog-languages.opml" "player-fm-en-featured-prog-languages.opml"
MirrorOPML "https://player.fm/en/featured/project-management.opml" "player-fm-en-featured-project-management.opml"
MirrorOPML "https://player.fm/en/featured/reggae.opml" "player-fm-en-featured-reggae.opml"
MirrorOPML "https://player.fm/en/featured/relationship.opml" "player-fm-en-featured-relationship.opml"
MirrorOPML "https://player.fm/en/featured/religion.opml" "player-fm-en-featured-religion.opml"
MirrorOPML "https://player.fm/en/featured/retirement.opml" "player-fm-en-featured-retirement.opml"
MirrorOPML "https://player.fm/en/featured/retro.opml" "player-fm-en-featured-retro.opml"
MirrorOPML "https://player.fm/en/featured/rock.opml" "player-fm-en-featured-rock.opml"
MirrorOPML "https://player.fm/en/featured/rugby.opml" "player-fm-en-featured-rugby.opml"
MirrorOPML "https://player.fm/en/featured/sci-fi-fantasy-stories.opml" "player-fm-en-featured-sci-fi-fantasy-stories.opml"
MirrorOPML "https://player.fm/en/featured/science-education.opml" "player-fm-en-featured-science-education.opml"
MirrorOPML "https://player.fm/en/featured/science.opml" "player-fm-en-featured-science.opml"
MirrorOPML "https://player.fm/en/featured/self-improvement.opml" "player-fm-en-featured-self-improvement.opml"
MirrorOPML "https://player.fm/en/featured/sexuality.opml" "player-fm-en-featured-sexuality.opml"
MirrorOPML "https://player.fm/en/featured/short-stories.opml" "player-fm-en-featured-short-stories.opml"
MirrorOPML "https://player.fm/en/featured/skateboarding.opml" "player-fm-en-featured-skateboarding.opml"
MirrorOPML "https://player.fm/en/featured/skating.opml" "player-fm-en-featured-skating.opml"
MirrorOPML "https://player.fm/en/featured/skeptic.opml" "player-fm-en-featured-skeptic.opml"
MirrorOPML "https://player.fm/en/featured/soccer.opml" "player-fm-en-featured-soccer.opml"
MirrorOPML "https://player.fm/en/featured/social-sciences.opml" "player-fm-en-featured-social-sciences.opml"
MirrorOPML "https://player.fm/en/featured/society.opml" "player-fm-en-featured-society.opml"
MirrorOPML "https://player.fm/en/featured/software-development.opml" "player-fm-en-featured-software-development.opml"
MirrorOPML "https://player.fm/en/featured/soul.opml" "player-fm-en-featured-soul.opml"
MirrorOPML "https://player.fm/en/featured/soundtrack.opml" "player-fm-en-featured-soundtrack.opml"
MirrorOPML "https://player.fm/en/featured/specialized-news.opml" "player-fm-en-featured-specialized-news.opml"
MirrorOPML "https://player.fm/en/featured/sports-and-entertainment.opml" "player-fm-en-featured-sports-and-entertainment.opml"
MirrorOPML "https://player.fm/en/featured/sports-betting.opml" "player-fm-en-featured-sports-betting.opml"
MirrorOPML "https://player.fm/en/featured/sports-coaching.opml" "player-fm-en-featured-sports-coaching.opml"
MirrorOPML "https://player.fm/en/featured/sports-medicine.opml" "player-fm-en-featured-sports-medicine.opml"
MirrorOPML "https://player.fm/en/featured/sports.opml" "player-fm-en-featured-sports.opml"
MirrorOPML "https://player.fm/en/featured/storytelling.opml" "player-fm-en-featured-storytelling.opml"
MirrorOPML "https://player.fm/en/featured/survival.opml" "player-fm-en-featured-survival.opml"
MirrorOPML "https://player.fm/en/featured/taxation.opml" "player-fm-en-featured-taxation.opml"
MirrorOPML "https://player.fm/en/featured/teaching.opml" "player-fm-en-featured-teaching.opml"
MirrorOPML "https://player.fm/en/featured/tech-education.opml" "player-fm-en-featured-tech-education.opml"
MirrorOPML "https://player.fm/en/featured/tech-news.opml" "player-fm-en-featured-tech-news.opml"
MirrorOPML "https://player.fm/en/featured/tech-tips.opml" "player-fm-en-featured-tech-tips.opml"
MirrorOPML "https://player.fm/en/featured/tech.opml" "player-fm-en-featured-tech.opml"
MirrorOPML "https://player.fm/en/featured/tennis.opml" "player-fm-en-featured-tennis.opml"
MirrorOPML "https://player.fm/en/featured/travel.opml" "player-fm-en-featured-travel.opml"
MirrorOPML "https://player.fm/en/featured/true-crime.opml" "player-fm-en-featured-true-crime.opml"
MirrorOPML "https://player.fm/en/featured/true-stories.opml" "player-fm-en-featured-true-stories.opml"
MirrorOPML "https://player.fm/en/featured/tv.opml" "player-fm-en-featured-tv.opml"
MirrorOPML "https://player.fm/en/featured/ufos.opml" "player-fm-en-featured-ufos.opml"
MirrorOPML "https://player.fm/en/featured/ukulele.opml" "player-fm-en-featured-ukulele.opml"
MirrorOPML "https://player.fm/en/featured/urbanism.opml" "player-fm-en-featured-urbanism.opml"
MirrorOPML "https://player.fm/en/featured/varsity-teams.opml" "player-fm-en-featured-varsity-teams.opml"
MirrorOPML "https://player.fm/en/featured/venture-capital.opml" "player-fm-en-featured-venture-capital.opml"
MirrorOPML "https://player.fm/en/featured/video-game-music.opml" "player-fm-en-featured-video-game-music.opml"
MirrorOPML "https://player.fm/en/featured/video-games.opml" "player-fm-en-featured-video-games.opml"
MirrorOPML "https://player.fm/en/featured/voice-acting.opml" "player-fm-en-featured-voice-acting.opml"
MirrorOPML "https://player.fm/en/featured/volleyball.opml" "player-fm-en-featured-volleyball.opml"
MirrorOPML "https://player.fm/en/featured/womens-corner.opml" "player-fm-en-featured-womens-corner.opml"
MirrorOPML "https://player.fm/en/featured/womens-health.opml" "player-fm-en-featured-womens-health.opml"
MirrorOPML "https://player.fm/en/featured/youtube.opml" "player-fm-en-featured-youtube.opml"

# PodcastIndex.ogr - V4V enabled
MirrorOPML "https://stats.podcastindex.org/v4vmusic.opml" "podcastindex-org-value4value-music.opml"

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
MirrorOPML "http://ladyofsituations.com/custom/people.opml" "ladyofsituations-custom-people.opml"
MirrorOPML "http://media.phlow.de/download/rss/podcast.opml" "phlow-de-podcasts.opml"
MirrorOPML "http://rasterweb.net/raster/feeds/wisconsin.opml" "rasterweb-net-wisconsin.opml"
MirrorOPML "http://rss.sina.com.cn/sina_all_opml.xml" "sina-com-cn-all.opml"
MirrorOPML "http://www.marshallk.com/politicalaudio.aspx.xml" "marshalls-politicalaudio.opml"
MirrorOPML "https://ainali.com/listening/feed.opml" "ainali-listening.opml"
MirrorOPML "https://chrisabraham.com/opml/at_download/file" "chrisabreaham.opml"
MirrorOPML "https://dave.sobr.org/enc/1662343807.433_polishpodcastdirectoryopml.xml" "podkasty-info-katalog-podkastow.opml"
MirrorOPML "https://defaria.com/podcasts.opml" "defaria-podcasts.opml"
MirrorOPML "https://dhruv-sharma.ovh/files/podcasts.opml" "dhruv-sharma.opml"
MirrorOPML "https://digiper.com/dl/digiper.opml" "digiper.opml"
MirrorOPML "https://inkdroid.org/podcasts/feed.opml" "inkdroid-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/Cj-Malone/Linux-Podcasts/master/feeds.opml" "cj-malone-linux-podcasts.opml"
MirrorOPML "https://raw.githubusercontent.com/marklogic-community/feed/master/test-scripts/data/opml_podcast.opml" "marklogic-community.opml"
MirrorOPML "https://raw.githubusercontent.com/OpenScienceRadio/Open-Science-Radio-Shownotes/master/OSR021/Auszug_Wissenschaftspodcasts_MFR_2014-06-03.opml" "openscienceradio-20140603.opml"
MirrorOPML "https://raw.githubusercontent.com/topgold/listening/master/fm.opml" "topgold-fm.opml"
MirrorOPML "https://raw.githubusercontent.com/yasuharu519/opml/master/main.opml" "yasuhary519.opml"
MirrorOPML "https://redecentralize.org/redigest/2022/kthxbye/redigest_feed_recommendations.opml" "redecentralize-redigest-feed-reccommendations.opml"
MirrorOPML "https://source.mcwhirter.io/craige/rcfiles/raw/branch/consensus/.gpodder.opml" "mcwhirter-craige-consensus-gpodder.opml"
MirrorOPML "https://typlog.com/podlist/opml.xml" "typlog-pod.opml"
MirrorOPML "https://welcometochina.com.au/wp-content/uploads/china-podcasts.opml" "welcomtochina-china-podcasts.opml"
MirrorOPML "https://wissenschaftspodcasts.de/opml-export/" "wissenschafts-podcasts.opml"
MirrorOPML "https://www.ancientfaith.com/feeds/podcasts.opml" "ancientfaith-podcasts.opml"

MirrorOPML "https://chillr.de/wp-content/uploads/Podcast20150707.opml" "chillr-de-podcast20150707.opml"

MirrorOPML "https://www.apreche.net/~apreche/podcasts.opml" "apreche-podcasts.opml"
MirrorOPML "http://nevillehobson.com/pubfiles/060508-NH-primary1-exp.opml" "nevillehobson-com-060508-NH-primary1-exp.opml"

MirrorOPML "http://mirrors.fe.up.pt/kde-applicationdata/amarok/podcast_directory/developer_podcasts.opml" "amarok-developer_podcasts.opml"

#MirrorOPML "http://podgallery.org/opml/?1" "podgallery-org-opml-01.opml"

#MirrorOPML "http://podgallery.org/opml/?10" "podgallery-org-opml-10.opml"
#MirrorOPML "http://podgallery.org/opml/?12" "podgallery-org-opml-12.opml"
#MirrorOPML "http://podgallery.org/opml/?13" "podgallery-org-opml-13.opml"
#MirrorOPML "http://podgallery.org/opml/?14" "podgallery-org-opml-14.opml"
#MirrorOPML "http://podgallery.org/opml/?15" "podgallery-org-opml-15.opml"
#MirrorOPML "http://podgallery.org/opml/?16" "podgallery-org-opml-16.opml"
#MirrorOPML "http://podgallery.org/opml/?17" "podgallery-org-opml-17.opml"
#MirrorOPML "http://podgallery.org/opml/?18" "podgallery-org-opml-18.opml"
#MirrorOPML "http://podgallery.org/opml/?19" "podgallery-org-opml-19.opml"

#MirrorOPML "http://podgallery.org/opml/?21" "podgallery-org-opml-21.opml"
#MirrorOPML "http://podgallery.org/opml/?23" "podgallery-org-opml-23.opml"
#MirrorOPML "http://podgallery.org/opml/?24" "podgallery-org-opml-24.opml"
#MirrorOPML "http://podgallery.org/opml/?25" "podgallery-org-opml-25.opml"
#MirrorOPML "http://podgallery.org/opml/?29" "podgallery-org-opml-29.opml"
#MirrorOPML "http://podgallery.org/opml/?30" "podgallery-org-opml-30.opml"
#MirrorOPML "http://podgallery.org/opml/?32" "podgallery-org-opml-32.opml"
#MirrorOPML "http://podgallery.org/opml/?33" "podgallery-org-opml-33.opml"
#MirrorOPML "http://podgallery.org/opml/?34" "podgallery-org-opml-34.opml"
#MirrorOPML "http://podgallery.org/opml/?35" "podgallery-org-opml-35.opml"
#MirrorOPML "http://podgallery.org/opml/?37" "podgallery-org-opml-37.opml"
#MirrorOPML "http://podgallery.org/opml/?38" "podgallery-org-opml-38.opml"
#MirrorOPML "http://podgallery.org/opml/?41" "podgallery-org-opml-41.opml"

MirrorOPML "http://hosting.opml.org/dnorman/educationpodcasts.opml" "opml-org-dnorman-educationpodcasts.opml"
MirrorOPML "https://jchk.net/files/Podcasts.opml" "jchk-net-files-podcasts.opml"

MirrorOPML "https://raw.githubusercontent.com/marklogic-community/feed/master/test-scripts/data/opml_podcast.opml" "marklogic-community.opml"
MirrorOPML "https://raw.githubusercontent.com/topgold/listening/master/fm.opml" "topgold.opml"
