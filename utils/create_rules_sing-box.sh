#!/usr/bin/bash
#
export LANG=en_US.UTF-8
export CHARSET=UTF-8
export NAME_ACCOUNT_GITHUB=you-oops-dev
#
export HOME_GITHUB=$(pwd)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${HOME_GITHUB}/utils
export SORT_PATH=/tmp/

cd $HOME_GITHUB/templates/sing-box

# domain
cat ../dnsmasq/dnsmasq.d/unblock.conf | awk -F / '{print $2}' | sort -T ${SORT_PATH} | uniq | sed '/googlevideo.com/d' | sed '/fastly.net/d' | sed '/discord.gg/d' | sed '/discord.com/d' | sed '/steamserver.net/d' | sed '/themoviedb.org/d' | sed '/voidboost.cc/d' | sed '/jetbrains.com/d' | sed '/intel.com/d' | sed '/archlinux.org/d' | sed '/windows.net/d' | sed '/cloudflareinsights.com/d' | sed '/microsoft.com/d' | sed '/steampowered.com/d' | sed '/akamai.net/d' | sed '/steamcloud-eu-ams.storage.googleapis.com/d' | sed '/steamcontent.com/d' | sed '/steamstatic.com/d' | sed '/steammobile.akamaized.net/d' | sed '/steamcommunity.com/d' | sed '/steamcloud-eu-fra.storage.googleapis.com/d' | sed '/ggpht.com/d' | sed '/googleapis.com/d' | sed '/googleusercontent.com/d' | sed '/gstatic.com/d' | sed '/returnyoutubedislikeapi.com/d' | sed '/returnyoutubedislike.com/d' | sed '/ajay.app/d' | sed '/ytimg.com/d' | sed '/yting.com/d' | sed '/tmdb.org/d' | sed '/cloudfront.net/d' | sed '/entware.net/d' | sed '/habr.com/d' | sed '/4pda.ru/d' | sed '/4pda.to/d' | sed '/4pda.ws/d' | sed '/torproject.org/d' | sed '/openai.com/d' | sed '/chatgpt.com/d' | sed '/spotify.com/d' | sed '/spotifycdn.com/d' | sed '/scdn.co/d' | sed '/whatsapp.net/d' | sed '/whatsapp.com/d' | sed '/fbcdn.net/d' | sed '/facebook.com/d' > ./domain.txt
# IP-address 1
#cat ../ipset/unblock_static.conf.zst | zstd -d | awk '{print $3}' | sed '/:/d' | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | sed 's/$/\/32/' > ./ip.txt
#
# IP-address 2
URL_LIST="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/discord/ipv4_smart.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/cloudflare/ipv4_smart.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/telegram/ipv4_smart.txt"
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# ${URL_LIST} | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | grep -i "/" > ./ip.txt
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# ${URL_LIST} | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | grep -v "/" | sed 's/$/\/32/' >> ./ip.txt
#

# domain wildcald
echo ".fastly.net
.googlevideo.com
.youtube.com
.discord.gg
.discord.com
.steamserver.net
.themoviedb.org
.tmdb.org
.voidboost.cc
.jetbrains.com
.intel.com
.archlinux.org
.windows.net
.cloudflareinsights.com
.microsoft.com
.steampowered.com
.akamai.net
.steamcloud-eu-ams.storage.googleapis.com
.steamcloud-eu-fra.storage.googleapis.com
.steamcontent.com
.steamstatic.com
.steammobile.akamaized.net
.steamcommunity.com
.googleapis.com
.googleusercontent.com
.gstatic.com
.returnyoutubedislikeapi.com
.returnyoutubedislike.com
.ajay.app
.ytimg.com
.yting.com
.ggpht.com
.cloudfront.net
.entware.net
.habr.com
.4pda.ws
.4pda.to
.4pda.ru
.torproject.org
.openai.com
.chatgpt.com
.spotify.com
.spotifycdn.com
.scdn.co
.whatsapp.net
.whatsapp.com
.fbcdn.net
.facebook.com" > ./domain_wildcard.txt


jq -n \
    --slurpfile domain_data <(jq -R . domain.txt) \
    --slurpfile domain_wildcard_data <(jq -R . domain_wildcard.txt) \
    --slurpfile ip_cidr_data <(jq -R . ip.txt) '
{
  version: 1,
  rules: [
   {
      domain: $domain_data,
      domain_suffix: $domain_wildcard_data,
      ip_cidr: $ip_cidr_data
   }
  ]
}' > re-filter-list-plus.json

sing-box rule-set compile re-filter-list-plus.json

exit 0
