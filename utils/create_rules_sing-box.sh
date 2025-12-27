#!/usr/bin/bash
#
export LANG=en_US.UTF-8
export CHARSET=UTF-8
export NAME_ACCOUNT_GITHUB=you-oops-dev
#
export HOME_GITHUB=$(pwd)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${HOME_GITHUB}/utils
export SORT_PATH=/tmp/

if [[ $1 == prepare ]]; then
cd $HOME_GITHUB/templates/sing-box

# domain
cat ../dnsmasq/dnsmasq.d/unblock.conf | awk -F / '{print $2}' | sort -T ${SORT_PATH} | uniq | sed '/googlevideo.com/d' | sed '/fastly.net/d' | sed '/discord.gg/d' | sed '/discord.com/d' | sed '/steamserver.net/d' | sed '/themoviedb.org/d' | sed '/voidboost.cc/d' | sed '/jetbrains.com/d' | sed '/intel.com/d' | sed '/archlinux.org/d' | sed '/windows.net/d' | sed '/cloudflareinsights.com/d' | sed '/microsoft.com/d' | sed '/steampowered.com/d' | sed '/akamai.net/d' | sed '/steamcloud-eu-ams.storage.googleapis.com/d' | sed '/steamcontent.com/d' | sed '/steamstatic.com/d' | sed '/akamaized.net/d' | sed '/steamcommunity.com/d' | sed '/steamcloud-eu-fra.storage.googleapis.com/d' | sed '/ggpht.com/d' | sed '/googleapis.com/d' | sed '/googleusercontent.com/d' | sed '/gstatic.com/d' | sed '/returnyoutubedislikeapi.com/d' | sed '/returnyoutubedislike.com/d' | sed '/ajay.app/d' | sed '/ytimg.com/d' | sed '/yting.com/d' | sed '/tmdb.org/d' | sed '/cloudfront.net/d' | sed '/entware.net/d' | sed '/habr.com/d' | sed '/4pda.ru/d' | sed '/4pda.to/d' | sed '/4pda.ws/d' | sed '/torproject.org/d' | sed '/openai.com/d' | sed '/chatgpt.com/d' | sed '/spotify.com/d' | sed '/spotifycdn.com/d' | sed '/scdn.co/d' | sed '/whatsapp.net/d' | sed '/whatsapp.com/d' | sed '/fbcdn.net/d' | sed '/facebook.com/d' | sed '/kinoxa.win/d' | sed '/^youtube.com/d' | sed '/youtube.com/d' | sed '/youtube/d' | sed '/tiktokcdn.com/d' | sed '/githubusercontent.com/d' | sed '/sinema2.top/d' | sed '/megapeer.ru/d' | sed '/pirat.one/d' | sed '/lordfillms.ru/d' | sed '/lordfilm.lu/d' | sed '/byteoversea.net/d' | sed '/google.com/d' | sed '/github.io/d' | sed '/blogspot.com/d' | sed '/musical.ly/d' | sed '/tiktokv.com/d' | sed '/lordserialus.fun/d' | sed '/akamaihd.net/d' | sed '/byteoversea.com/d' | sed '/azotmarket.ru/d' | sed '/kinoteatr.one/d' | sed '/tiktokcdn-eu.com/d' | sed '/ibyteimg.com/d' | sed '/deepl.com/d' | sed '/x.com/d' | sed '/instagram/d' | sort -T ${SORT_PATH} | uniq > ./domain.txt
echo "youtube.com
www.youtube.com
www.instagram.com
www.facebook.com
deepl.com
www.deepl.com
x.com
www.x.com
www.intel.com
intel.com
amd.com
www.amd.com
youtu.be
www.youtu.be" >> ./domain.txt
sort -T ${SORT_PATH} ./domain.txt | uniq | sponge ./domain.txt
# IP-address 1
#cat ../ipset/unblock_static.conf.zst | zstd -d | awk '{print $3}' | sed '/:/d' | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | sed 's/$/\/32/' > ./ip.txt
#
# IP-address 2
#URL_LIST="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/discord/ipv4_smart.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/cloudflare/ipv4_smart.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/telegram/ipv4_smart.txt"
#curl --max-time 30 --retry-delay 3 --retry 10 -4 -# ${URL_LIST} | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | grep -i "/" > ./ip.txt
#curl --max-time 30 --retry-delay 3 --retry 10 -4 -# ${URL_LIST} | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | grep -v "/" | sed 's/$/\/32/' >> ./ip.txt
#
# IP-address 3 from resolving-public
URL_LIST="https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/resolving-public/refs/heads/main/unblock_suite_with_ip_hoster_border_ipset.txt"
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# ${URL_LIST} | sort -T ${SORT_PATH} -t. -k1,1n -k2,2n -k3,3n -k4,4n | uniq | grep -i "/" > ./ip.txt
#

# domain wildcald
echo ".fastly.net
.googlevideo.com
.youtube.com
.youtu.be
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
.akamaized.net
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
.facebook.com
.kinoxa.win
.tiktokcdn.com
.sinema2.top
.githubusercontent.com
.megapeer.ru
.pirat.one
.lordfillms.ru
.lordfilm.lu
.byteoversea.net
.google.com
.github.io
.blogspot.com
.musical.ly
.tiktokv.com
.lordserialus.fun
.instagram.com
.akamaihd.net
.byteoversea.com
.kinoteatr.one
.tiktokcdn-eu.com
.ibyteimg.com
.deepl.com
.x.com
.amd.com" > ./domain_wildcard.txt

cat domain_wildcard.txt domain.txt | sort | uniq > domain_all.txt
fi

if [[ $1 == gen ]]; then

cd $HOME_GITHUB/templates/sing-box


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
}' > refilter_plus.json

name=refilter_plus
sing-box rule-set compile ${name}.json
mv -f ${name}.json ${name}.txt
mv -f ${name}.srs ${name}.jq

chmod -c 755 $HOME_GITHUB/utils/generate-geoip-geosite-lin64

PATH_GEN=/tmp
rm -f ${PATH_GEN}/*.{lst,srs,json,db} ./*.zip
# Gen adlist,refilter_plus
generate-geoip-geosite-lin64 -s source.json -i ${PATH_GEN}/ -o ${PATH_GEN}/

# adlist
mv -fv ${PATH_GEN}/include-domain-adlist.lst ./adlist.lst
mv -fv ${PATH_GEN}/ruleset-domain-adlist.json ./adlist.json
mv -fv ${PATH_GEN}/ruleset-domain-adlist.srs ./adlist.srs

# refilter_plus domain
mv -fv ${PATH_GEN}/include-domain-refilter_plus_domains.lst ./refilter_plus_domains.lst
mv -fv ${PATH_GEN}/ruleset-domain-refilter_plus_domains.json ./refilter_plus_domains.json
mv -fv ${PATH_GEN}/ruleset-domain-refilter_plus_domains.srs ./refilter_plus_domains.srs

# refilter_plus ip
mv -fv ${PATH_GEN}/include-ip-refilter_plus_ipsum.lst ./refilter_plus_ipsum.lst
mv -fv ${PATH_GEN}/ruleset-ip-refilter_plus_ipsum.json ./refilter_plus_ipsum.json
mv -fv ${PATH_GEN}/ruleset-ip-refilter_plus_ipsum.srs ./refilter_plus_ipsum.srs

# Both domain and IP (refilter_plus)
name=refilter_plus
mv -f ${name}.txt ${name}-all.json
mv -f ${name}.jq ${name}-all.srs

# DataBase
mv -fv ${PATH_GEN}/geoip.db ./
mv -fv ${PATH_GEN}/geosite.db ./

dos2unix *.lst *.json
# Download CIDR prefix country for exclude (husi)
#for countries in {ru,by}; do curl --max-time 90 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/country/"$countries"/"$countries".srs | tee -i ./"$countries".srs &>/dev/null; done
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/country/ru/ru.srs -P ./
#YouTube
name_service=youtube
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#ChatGPT
name_service=chatgpt
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#4pda
name_service=4pda
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Spotify
name_service=spotify
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Intel
name_service=intel
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#microsoft
name_service=microsoft
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Rezka
name_service=rezka
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Arch Linux
name_service=arch
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Steam
name_service=steam
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Tor
name_service=tor
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Roblox
name_service=roblox
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./
#Discord
name_service=discord
wget -4nv https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges-singbox/refs/heads/main/${name_service}/${name_service}.srs -P ./

# Compress zip archive
zip -9 sb-rules.zip ./*.srs
fi

exit 0
