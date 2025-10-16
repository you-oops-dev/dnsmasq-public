#!/usr/bin/env bash

auto_reboot_service_after_upd_list=n

if [ "$UID" -ne "0" ]; then
    echo -e "\n\e[0;33m[${0##*/}]\e[1;31m Error: \e[0;33mYOU MUST BE ROOT TO USE THIS!"
    echo -e "\e[0;35mTip: \e[0;33mPrecede your command with 'sudo'\e[0m\n"
    exit 1
fi
USERNAME=root
export HOME_GITHUB=$(pwd)
export LANG=en_US.UTF-8
export CHARSET=UTF-8


delele_dir(){
    rm -rf /tmp/filter/
}

if [[ -d /tmp/filter ]]; then
    echo "Очистка существующих листов..."
    delele_dir
fi

if [[ -f /tmp/01_unbound_filters.hostname ]]; then
    rm /tmp/01_unbound_filters.hostname
fi

if [[ -f /etc/unbound/unbound.conf.d/01_unbound_filters.conf ]]; then
    rm /etc/unbound/unbound.conf.d/01_unbound_filters.conf
fi

echo ""

mkdir -pv /tmp/filter/
echo "Загрузка листа... Содержит домена трекеров"
wget -nv -4 -O /tmp/filter/Airelle-trc.hostname https://v.firebog.net/hosts/Airelle-trc.txt
echo ""

echo "YouTube ads block..."
wget -4q -nv -O - https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Adblock-YouTube-Ads.txt | awk -F\# '$1!="" { print $1 ;}' | sed '/#/d' | sort -T /root/ | uniq > /tmp/filter/youtube_ads.hostname

echo "Загрузка листа... Содержит домена трекеров"
wget -nv -4 -P /tmp/filter/ https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
sed -i '/vortex.data.microsoft.com/d; /vortex-win.data.microsoft.com/d' /tmp/filter/spy.txt
cat /tmp/filter/spy.txt | awk -F\# '$1!="" { print $1 ;}' | awk '{print $2}' > /tmp/filter/spy.hostname
echo ""

wget -nv -4 -P /tmp/filter/ https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
cat /tmp/filter/Mandiant_APT1_Report_Appendix_D.txt | sed '/#/d' | sort -T /root/ | uniq > /tmp/filter/Mandiant_APT1_Report_Appendix_D.hostname
rm -fv /tmp/filter/Mandiant_APT1_Report_Appendix_D.txt

wget -4q -nv -O - https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts | sed 's/0.0.0.0 //g' | sed '/#/d' | sort -T /root/ | uniq > /tmp/filter/add_Risk.hostname

wget -4q -nv -O - https://raw.githubusercontent.com/DRSDavidSoft/additional-hosts/master/domains/blacklist/fake-domains.txt | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/ //g' | sed '/#/d' | sort -T /root/ | uniq > /tmp/filter/fake-domains.hostname

wget -4q -nv -O - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/:/d' | sed '/ip6/d' | sed '/!/d' | sed '/#/d' | sed 's/ //g' | sort -T /root/ | uniq > /tmp/filter/gambling-social.hostname

wget -4q -nv -O - https://adblock.mahakala.is/ | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/:/d' | sed '/ip6/d' | sed '/!/d' | sed '/#/d' | sed 's/ //g' | sort -T /root/ | uniq > /tmp/filter/mahakala.hostname

wget -4q -nv -O - https://block.energized.pro/blu/formats/domains.txt | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/:/d' | sed '/ip6/d' | sed '/!/d' | sed '/#/d' | sed 's/ //g' | sort -T /root/ | uniq > /tmp/filter/energized.hostname

wget -4q -nv -O - https://raw.githubusercontent.com/DataMaster-2501/DataMaster-Android-AdBlock-Hosts/master/hosts | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/:/d' | sed '/ip6/d' | sed '/!/d' | sed '/#/d' | sed 's/ //g' | sort -T /root/ | uniq > /tmp/filter/DataMaster.hostname

wget -4q -nv -O - https://raw.githubusercontent.com/blocklistproject/Lists/master/scam.txt | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/ //g' | sed '/#/d' | sort -T /root/ | uniq > /tmp/filter/scam.hostname

echo "Загрузка список хостов TikTok (но не включаем его)"
wget -nv -4 -P /tmp/filter/ https://raw.githubusercontent.com/d43m0nhLInt3r/socialblocklists/master/TikTok/tiktokblocklistWithoutRegex.txt
cat /tmp/filter/tiktokblocklistWithoutRegex.txt | awk '{print $2}' > /tmp/filter/tiktok_block.hostname_off
echo ""

echo "Загрузка листа... Содержит домена вредоностных сайтов с вредоностным ПО..."
wget -4 -nv -P /tmp/filter/ https://urlhaus.abuse.ch/downloads/hostfile/
#Конвертирование DOS>UTF-8
tr -d '\r' < /tmp/filter/index.html > /tmp/filter/index.utf8
rm /tmp/filter/index.html
cat /tmp/filter/index.utf8 | awk -F\# '$1!="" { print $1 ;}' | grep -i 127.0.0.1 | awk '{print $2}' > /tmp/filter/index.hostname
rm /tmp/filter/index.utf8
echo ""

#echo "Загрузка листа... Содержит домена вредоностных сайтов с вредоностным ПО..." #Майнинг браузерный (нужно парсить было без стало с ним)
#wget -4 -nv -O /tmp/filter/list.hostname_off https://gitlab.com/ZeroDot1/CoinBlockerLists/raw/master/list.txt
#echo ""

echo "Загрузка листа... Содержит домена для блокировки рекламы.Оч.Жесткая блокировка"
wget -nv -4 -P /tmp/filter/ https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds-Ultra.txt
#Чистка
cat /tmp/filter/GoodbyeAds-Ultra.txt | awk -F\# '$1!="" { print $1 ;}' | grep -i 0.0.0.0 | sed '/0.0.0.0 0.0.0.0/d' | awk '{print $2}' > /tmp/filter/GoodbyeAds-Ultra.hostname
echo ""

echo "Загрузка листа... Содержит домена для блокировки Facebook..."
wget -nv -4 -P /tmp/filter/ https://github.com/d43m0nhLInt3r/socialblocklists/raw/master/Facebook/facebookblocklist.txt
#Чистка от закоментированых строк
cat /tmp/filter/facebookblocklist.txt | awk '{print $2}' > /tmp/filter/facebookblocklist.hostname.hostname_off
echo ""

echo "Загрузка листа... Содержит домена для блокировки Майнеров..."
wget -nv -4 -O /tmp/filter/adblock-nocoin.txt https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
#Чистка от закоментированых строк
cat /tmp/filter/adblock-nocoin.txt | awk -F\# '$1!="" { print $1 ;}' | awk '{print $2}' > /tmp/filter/adblock-nocoin.hostname
echo ""

echo "Загрузка листа... Многоцелевой"
wget -nv -4 -O /tmp/filter/serverlist.php https://pgl.yoyo.org/adservers/serverlist.php
#Чистка от HTML-кода
cat /tmp/filter/serverlist.php | sed 's/<\/*[^>]*>//g' | grep ^127.0.0.1 | awk '{print $2}' > /tmp/filter/serverlist.hostname
echo ""

echo "Загрузка листа для блокировки рекламы..."
wget -nv -4 -O /tmp/filter/01_hosts.txt https://raw.githubusercontent.com/Yhonay/antipopads/master/hosts
cat /tmp/filter/01_hosts.txt | awk -F\# '$1!="" { print $1 ;}' | awk '{print $2}' > /tmp/filter/antipopads.hostname
echo ""

##Блокирует платные подписки от ОПСОС
echo "Загрузка листа... Содержит домена для блокировки wap-click..."
#BEELINE
wget -4 -nv -O /tmp/filter/wapclick_beeline.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_wapclick_beeline_podpiski_all
#MEGAFON
wget -4 -nv -O /tmp/filter/wapclick_megafon.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_wapclick_megafon_all
#MEGAFON 2
wget -4 -nv -O /tmp/filter/wapclick_megafon2.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_wapclick_megafon_podpiski_all
#MTS
wget -4 -nv -O /tmp/filter/wapclick_mts.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_wapclick_mts_podpiski_all
#ALL
wget -4 -nv -O /tmp/filter/wapclick_all.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_wapclick_all
cat /tmp/filter/wapclick_*.txt | awk -F\! '$1!="" { print $1 ;}' | sort -T /root/ | uniq | sed '1d'  > /tmp/filter/01_anti_wapclick.hostname
#echo ""

#Блокировка онлайн-казино
echo "Загрузка листа... Содержит домена онлайн-казино..."
#Azino
wget -4 -nv -O /tmp/filter/01_azino.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_all_bets_are_off__azino7_all
#1xbet
wget -4 -nv -O /tmp/filter/01_1xbet.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_all_bets_are_off__1xbet_all
cat /tmp/filter/01_{azino,1xbet}.txt | awk -F\! '$1!="" { print $1 ;}' | sort -T /root/ | uniq | sed '1d' > /tmp/filter/01_casino.hostname
echo ""
echo "Блокировка рекламы"
wget -4 -nv -O /tmp/filter/RUAdListBitBlock.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListBitBlock.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock1.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListCounters.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock2.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RU-AdList.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock3.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/Russia.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock4.txt https://raw.githubusercontent.com/parseword/nolovia/master/skel/hosts-government-malware.txt
cat /tmp/filter/RUAdListBitBlock4.txt | sed '/#/d' | sed '/!/d' | sort -T /root/ | uniq > /tmp/filter/RUAdListBitBlock4.hostname
wget -4 -nv -O /tmp/filter/RUAdListBitBlock5.txt https://block.energized.pro/blu/formats/domains.txt
cat /tmp/filter/RUAdListBitBlock5.txt | sed '/#/d' | sed '/!/d' | sort -T /root/ | uniq > /tmp/filter/RUAdListBitBlock5.hostname
wget -4 -nv -O /tmp/filter/RUAdListBitBlock6.txt https://schakal.ru/hosts/alive_hosts.txt
cat /tmp/filter/RUAdListBitBlock6.txt | sed '/#/d' | awk -F\# '$1!="" { print $1 ;}' | grep -i 0.0.0.0 | sed '/0.0.0.0 0.0.0.0/d' | sed 's/^0.0.0.0 //g' | sort -T /root/ | uniq > /tmp/filter/RUAdListBitBlock6.hostname
wget -4 -nv -O /tmp/filter/RUAdListBitBlock7.txt https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardDNS.txt
cat /tmp/filter/RUAdListBitBlock7.txt | sed '/#/d' | awk -F\# '$1!="" { print $1 ;}' | grep -i 0.0.0.0 | sed '/0.0.0.0 0.0.0.0/d' | sed 's/^0.0.0.0 //g' | sort -T /root/ | uniq > /tmp/filter/RUAdListBitBlock7.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardSDNSFilter/refs/heads/master/Filters/rules.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed '/\//d' | sed '/\*/d' | sed 's/\^//g' | sed 's/||//g' >> /tmp/filter/RUAdListBitBlock7.hostname
sort -T /root/ /tmp/filter/RUAdListBitBlock7.hostname | uniq | sed 's/ /\n/g' | sed 's/ //g' | sed -r '/^\s*$/d' | sed 's/[<>]//g' | sed 's/^https\?:\/\///g' | sponge /tmp/filter/RUAdListBitBlock7.hostname
curl --max-time 180 --retry-delay 3 --retry 5 -4s https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/AdGuard/AdvertisingLite/AdvertisingLite.txt | sed '/#/d' | sed 's/!//g' | sed 's/||//g' | sed 's/\^//g' | sed '/[А-Я]/d' | sed '/[а-я]/d' | sort -T /root/ | uniq > /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://gitlab.com/kowith337/PersonalFilterListCollection/raw/master/hosts/hosts_google_adservice_id.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://dl.comss.org/download/Comss-filters.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
#4PDA Community hosts blacklist
wget -4q -nv -O - https://schakal.ru/hosts/hosts.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://schakal.ru/hosts/alive_hosts_ru_com.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://schakal.ru/hosts/alive_hosts_ru_com_zen.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/ABP-X-Files.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListCounters.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/allendema/noplaylist/main/NoPlayList.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/mvps-hosts-file.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/angelics/pfbng/master/ads/ads-domain-list.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/spotifyads.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/uAssetsFilters.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV-AGH.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/|//g' | sed 's/@//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/*/d' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/refs/heads/master/android-tracking.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/|//g' | sed 's/@//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/*/d' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sort | uniq | sed 's/\t//g' | sed 's/ //g' >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed '/ip6-/d' | sed '/255.255.255.255/d' | sed '/.localdomain/d' | sed '/fe80/d' | sed '/local/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/|//g' | sed 's/@//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/*/d' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sed 's/\t//g' | sed 's/ //g' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_15_DnsFilter/filter.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed '/ip6-/d' | sed '/255.255.255.255/d' | sed '/.localdomain/d' | sed '/fe80/d' | sed '/local/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/|//g' | sed 's/@//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/*/d' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sed 's/\t//g' | sed 's/ //g' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro-onlydomains.txt | sed '/#/d' | sed '/!/d' | sed '/!!/d' | sed '/ip6-/d' | sed '/255.255.255.255/d' | sed '/.localdomain/d' | sed '/fe80/d' | sed '/local/d' | sed 's/\^//g' | sed 's/||//g' | sed 's/|//g' | sed 's/@//g' | sed 's/127.0.0.1 localhost//g' | sed 's/::1 localhost//g' | sed 's/0.0.0.0 //g' | sed 's/127.0.0.1 //g' | sed '/*/d' | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sed 's/\t//g' | sed 's/ //g' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://www.cromite.org/filters/badmojr-1Hosts-master-Pro-adblock.txt | sed '/!/d' | sed 's/||//g' | sed 's/\^//g' | sed '/#/d' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Adblock-YouTube-Ads.txt | sed '/!/d' | sed '/#/d' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://winhelp2002.mvps.org/hosts.txt | sed '/!/d' | sed '/#/d' | sed '/127.0.0.1/d' | sed -r '/^\s*$/d' | awk '{print $2}' | uniq | sort >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://adaway.org/hosts.txt | sed '/!/d' | sed '/#/d' | sed -r '/^\s*$/d' | awk '{print $2}' | uniq | sort >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://hostsfile.mine.nu/Hosts | sed '/!/d' | sed '/#/d' | sed '/127.0.0.1     localhost/d' | sed -r '/^\s*$/d' | awk '{print $2}' | uniq | sort >> /tmp/filter/AdvertisingLite.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/Kittyskj/FreeFromMi/refs/heads/main/hosts | sed '/!/d' | sed '/#/d' | sed '/^127.0.0.1/d' | sed '/^255.255.255.255/d' | sed '/^\:\:1/d' | sed '/^fe80\:\:1\%lo0/d' | sed '/^ff00::0/d' | sed '/^ff02::1/d' | sed '/^ff02::2/d' | sed '/^ff02::3/d' | sed '/0.0.0.0 0.0.0.0/d' | sed -r '/^\s*$/d' | awk '{print $2}' | sort | uniq >> /tmp/filter/AdvertisingLite.hostname
echo ""

echo "Объеденение несколько списков в один список..."
cat /tmp/filter/*.hostname > /tmp/filter/unbound.hostname
echo ""

echo -e "\e[1;33mПовторно чистим на всякий пожарный случай...\033[0m"
sed -i 's/^0.0.0.0//g' /tmp/filter/unbound.hostname
sed -i 's/^127.0.0.1//g' /tmp/filter/unbound.hostname
sed -i '/#/d' /tmp/filter/unbound.hostname
sed -i 's/<\/*[^>]*>//g' /tmp/filter/unbound.hostname
sed -i 's/\t//g' /tmp/filter/unbound.hostname
sed -i '/\$/d' /tmp/filter/unbound.hostname
sed -i '/^!/d' /tmp/filter/unbound.hostname
sed -i '/^!!/d' /tmp/filter/unbound.hostname
#Чистим от киррилитических доменов
sed -i '/[А-Я]/d' /tmp/filter/unbound.hostname
sed -i '/[а-я]/d' /tmp/filter/unbound.hostname
#
sed -i 's/^ *//g' /tmp/filter/unbound.hostname
sed -i 's/ //g' /tmp/filter/unbound.hostname
sort /tmp/filter/unbound.hostname -T /root/ | uniq | sponge /tmp/filter/unbound.hostname
sed -i '1d' /tmp/filter/unbound.hostname
#######
##Блокировка
echo "iplogger.org
2no.co
iplogger.com
iplogger.ru
yip.su
iplogger.co
iplogger.info
ipgrabber.ru
ipgraber.ru
iplis.ru
02ip.ru
gatpsstat.com
fri-gate.org
frigateblocklist.com
fr11.friproxy.biz
uk11.friproxy.biz
apigo.fri-gate
ip.fri-gate.org
support.fri-gate.org
gatpsstat.com
www.expressvpn.com
expressvpn.com" >> /tmp/filter/unbound.hostname
##Реклама в приложениях
echo "pagead2.googlesyndication.com
mobile.yandexadexchange.net
googleads.g.doubleclick.net
firestore.googleapis.com" >> /tmp/filter/unbound.hostname
#Реклама от Яндекс
echo "report.appmetrica.yandex.net" >> /tmp/filter/unbound.hostname
#Реклама от Гугл
echo "userlocation.googleapis.com
ads.google.com
safebrowsing.googleapis.com" >> /tmp/filter/unbound.hostname
#Вариант рекламных хостов от d3ward.github.io
echo "pagead2.googlesyndication.com
adservice.google.com
pagead2.googleadservices.com
googleadservices.com
static.media.net
media.net
adservetx.media.net
doubleclick.net
ad.doubleclick.net
static.doubleclick.net
m.doubleclick.net
fastclick.com
fastclick.net
media.fastclick.net
cdn.fastclick.net
amazonaax.com
amazonclix.com
assoc-amazon.com
google-analytics.com
ssl.google-analytics.com
hotjar.com
static.hotjar.com
api-hotjar.com
hotjar-analytics.com
mouseflow.com
a.mouseflow.com
freshmarketer.com
luckyorange.com
cdn.luckyorange.com
w1.luckyorange.com
stats.wp.com
pixel.facebook.com
ads.facebook.com
an.facebook.com
static.ads-twitter.com
ads-api.twitter.com
ads.youtube.com
ads.yahoo.com
global.adserver.yahoo.com
analytics.yahoo.com
ads.yap.yahoo.com
appmetrica.yandex.com
yandexadexchange.net
analytics.mobile.yandex.net
adsdk.yandex.ru
an.yandex.ru
sba.yandex.net
report.appmetrica.yandex.net
favicon.yandex.net
samsungads.com
nmetrics.samsung.com
config.samsungads.com" >> /tmp/filter/unbound.hostname
echo "iplogger.org
2no.co
iplogger.com
iplogger.ru
yip.su
iplogger.co
iplogger.info
ipgrabber.ru
ipgraber.ru
iplis.ru
02ip.ru" >> /tmp/filter/unbound.hostname
echo "gatpsstat.com" >> /tmp/filter/unbound.hostname
#Fri-gate
echo "fri-gate.org" >> /tmp/filter/unbound.hostname
echo "frigateblocklist.com" >> /tmp/filter/unbound.hostname
echo "fr11.friproxy.biz" >> /tmp/filter/unbound.hostname
echo "uk11.friproxy.biz" >> /tmp/filter/unbound.hostname
echo "apigo.fri-gate" >> /tmp/filter/unbound.hostname
echo "ip.fri-gate.org" >> /tmp/filter/unbound.hostname
echo "support.fri-gate.org" >> /tmp/filter/unbound.hostname
echo "api3.fri-gate.eu" >> /tmp/filter/unbound.hostname
echo "api3.fri-gate0.eu" >> /tmp/filter/unbound.hostname
echo "api3.friproxy.biz" >> /tmp/filter/unbound.hostname
echo "api3.fri-gate.biz" >> /tmp/filter/unbound.hostname
echo "api3.friproxy0.org" >> /tmp/filter/unbound.hostname
echo "api3.friproxy.org" >> /tmp/filter/unbound.hostname
echo "s1814.frigateblocklist.com" >> /tmp/filter/unbound.hostname
echo "s814.frigateblocklist.com" >> /tmp/filter/unbound.hostname
echo "api.raygun.com" >> /tmp/filter/unbound.hostname
#######
sort /tmp/filter/unbound.hostname -T /root/ | uniq | sponge /tmp/filter/unbound.hostname

echo "Загрузка белого листа"
wget -4 -nv -O /tmp/filter/whitelist.hostname https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
wget -4q -nv -O - https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/firefox.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/banks.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/android.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/issues.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/mac.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/sensitive.txt https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/windows.txt https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-list.txt | sed '/\/\//d' | sed '/#/d' | sed '/\$/d' | sed 's/<\/*[^>]*>//g' | sort -T /root/ | uniq >> /tmp/filter/whitelist.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/whitelist/master/domains.list | sed '/REG/d' | sed '/[0-9].[0-9].[0-9].[0-9]/d' | sed 's/ALL .//g' | sed '/ALL/d' | sed '/RZD/d' | sed '/[А-Я]/d' | sed '/[а-я]/d' >> /tmp/filter/whitelist.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/EnergizedProtection/unblock/master/basic/formats/dnsmasq.conf | grep -i server= | awk -F / '{print $2}' >> /tmp/filter/whitelist.hostname
echo ""
cat /tmp/secret-list/whitelist.hostname >> /tmp/filter/whitelist.hostname
rm -fvr /tmp/secret-list/
sort -T /root/ /tmp/filter/whitelist.hostname | uniq | sed 's/ /\n/g' | sed 's/ //g' | sed -r '/^\s*$/d' | sed 's/[<>]//g' | sed 's/^https\?:\/\///g' | sponge /tmp/filter/whitelist.hostname
##Meta
wget -4q -nv -O - https://raw.githubusercontent.com/antonme/ipnames/refs/heads/master/dns-facebook.txt | sed '/REG/d' | sed '/[0-9].[0-9].[0-9].[0-9]/d' | sed 's/ALL .//g' | sed '/ALL/d' | sed '/RZD/d' | sed '/[А-Я]/d' | sed '/[а-я]/d' >> /tmp/filter/whitelist.hostname
wget -4q -nv -O - https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Facebook/Facebook.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/IP-ASN/d' >> /tmp/filter/whitelist.hostname
##Twitch
wget -4q -nv -O - https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Twitch/Twitch.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/IP-ASN/d' >> /tmp/filter/whitelist.hostname
##Instagramm
wget -4q -nv -O - https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Instagram/Instagram.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/IP-ASN/d' >> /tmp/filter/whitelist.hostname
##Twitter
wget -4q -nv -O - https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Twitter/Twitter.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/IP-ASN/d' >> /tmp/filter/whitelist.hostname
##GitHub
wget -4q -nv -O - https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/GitHub/GitHub.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/IP-ASN/d' >> /tmp/filter/whitelist.hostname
#Porn Suite
wget -4q -nv -O - https://raw.githubusercontent.com/Sinfonietta/hostfiles/master/pornography-hosts | sed 's/127.0.0.1//g' | sed 's/0.0.0.0//g' | sed 's/\t//g' | sed 's/ //g' | sort | uniq >> /tmp/filter/whitelist.hostname
#CDN Whiting list
wget -4q -nv -O - https://raw.githubusercontent.com/ShadowWhisperer/BlockLists/master/Whitelists/Whitelist | awk '{print $1}' | sed '/#/d' | sed 's/\t//g' | sed 's/ //g' | sort | uniq >> /tmp/filter/whitelist.hostname
echo ""

###
##Разблокировка
echo "Добавляем доп. свои хосты для разблокировки"
echo "piwik.opendesktop.org" >> /tmp/filter/whitelist.hostname #скачивание тем для KDE
echo "suggestqueries.google.com" >> /tmp/filter/whitelist.hostname #поисковые подсказки Google
echo "hl-img.peco.uodoo.com" >> /tmp/filter/whitelist.hostname #для работоспособности браузера UC Browser
echo "browser.cloud.ucweb.com" >> /tmp/filter/whitelist.hostname #для работоспособности браузера UC Browser
echo "gstaticadssl.l.google.com" >> /tmp/filter/whitelist.hostname #для корректной работы шрифтов от Google
echo "audio-ak-spotify-com.akamaized.net
wl.spotify.com
www.wl.spotify.com" >> /tmp/filter/whitelist.hostname #для корректного переключения Spotify на другое устройство
echo "stat.online.sberbank.ru" >> /tmp/filter/whitelist.hostname #для корректной работы приложения сбербанка
echo "rutracker.wiki" >> /tmp/filter/whitelist.hostname
echo "rutracker.org" >> /tmp/filter/whitelist.hostname
echo "thepiratebay.org" >> /tmp/filter/whitelist.hostname
echo "toptracker.ru" >> /tmp/filter/whitelist.hostname
echo "track24.ru" >> /tmp/filter/whitelist.hostname
echo "osm.wifly.net" >> /tmp/filter/whitelist.hostname
echo "wifly.net" >> /tmp/filter/whitelist.hostname
echo "dns.google" >> /tmp/filter/whitelist.hostname
echo "dns.nextdns.io" >> /tmp/filter/whitelist.hostname
echo "nextdns.io" >> /tmp/filter/whitelist.hostname
echo "www.bestchange.ru
bestchange.ru
www.bestchange.com
bestchange.com
www.bestchange.net
bestchange.net
moneroseeds.ae.org
moneroseeds.ae
moneroseeds.se.org
moneroseeds.ru
moneroseeds.ru.org
moneroseeds.ch
moneroseeds.ch.org" >> /tmp/filter/whitelist.hostname
echo "digiseller.ru
api.digiseller.ru" >> /tmp/filter/whitelist.hostname
echo "www.avito.ru
avito.ru
m.avito.ru
socket.avito.ru" >> /tmp/filter/whitelist.hostname
echo "cloudflareinsights.com" >> /tmp/filter/whitelist.hostname
echo "ttvnw.net
twitch.com
twitchcdn.net
k.twitchcdn.net" >> /tmp/filter/whitelist.hostname
echo "www.maxmind.com" >> /tmp/filter/whitelist.hostname
echo "maxmind.com" >> /tmp/filter/whitelist.hostname
echo "is.gd" >> /tmp/filter/whitelist.hostname #Для работы реферальной ссылки из канала в ТГ Free Steam
echo "secure.gravatar.com" >> /tmp/filter/whitelist.hostname #Для работы аватарок на GitLab
echo "googleadservices.com" >> /tmp/filter/whitelist.hostname
echo "miru.mobi" >> /tmp/filter/whitelist.hostname
echo "static.wikia.nocookie.net" >> /tmp/filter/whitelist.hostname
echo "gstatic.com" >> /tmp/filter/whitelist.hostname
echo "www.gstatic.com" >> /tmp/filter/whitelist.hostname
echo "darkreader.github.io" >> /tmp/filter/whitelist.hostname
echo "2ip.ru" >> /tmp/filter/whitelist.hostname
echo "services.fandom.com^" >> /tmp/filter/whitelist.hostname
echo "lu.api.mega.co.nz" >> /tmp/filter/whitelist.hostname
echo "g.api.mega.co.nz" >> /tmp/filter/whitelist.hostname
echo "mackeeper.com" >> /tmp/filter/whitelist.hostname
echo "ru.wix.com" >> /tmp/filter/whitelist.hostname
echo "duckdns.org" >> /tmp/filter/whitelist.hostname
echo "store.steampowered.com" >> /tmp/filter/whitelist.hostname
echo "dynv6.com" >> /tmp/filter/whitelist.hostname
echo "www.TradeInsights.net" >> /tmp/filter/whitelist.hostname #Удаление дубликата
echo "s.rbk.ru" >> /tmp/filter/whitelist.hostname
echo "cdn.cookielaw.org" >> /tmp/filter/whitelist.hostname
echo "play-fe.googleapis.com" >> /tmp/filter/whitelist.hostname #Не блокировать если заблокируешь сломаю GP в телефоне
echo "clck.yandex.ru" >> /tmp/filter/whitelist.hostname
echo "fastly.net" >> /tmp/filter/whitelist.hostname
echo "map.fastly.net" >> /tmp/filter/whitelist.hostname
echo "www.map.fastly.net" >> /tmp/filter/whitelist.hostname
echo "www.fastly.net" >> /tmp/filter/whitelist.hostname
echo "tricolor.ru" >> /tmp/filter/whitelist.hostname
##Spotify
echo "sentry.io" >> /tmp/filter/whitelist.hostname
## URL shorteners
echo "adf.ly" >> /tmp/filter/whitelist.hostname
echo "bit.ly" >> /tmp/filter/whitelist.hostname
echo "goo.gl" >> /tmp/filter/whitelist.hostname
echo "ow.ly" >> /tmp/filter/whitelist.hostname
##
echo "ads.adfox.ru" >> /tmp/filter/whitelist.hostname #Метро MT_FREE
echo "rose.ixbt.com" >> /tmp/filter/whitelist.hostname #ixbt.com (просмотр видео)
echo "tracker.opentrackr.org" >> /tmp/filter/whitelist.hostname #Торрент-трекер
echo "pp.ru" >> /tmp/filter/whitelist.hostname #Для работы репозитория
echo "expressvpn.com" >> /tmp/filter/whitelist.hostname
echo "www.expressvpn.com" >> /tmp/filter/whitelist.hostname
echo "app.appsflyer.com" >> /tmp/filter/whitelist.hostname
echo "www.app.appsflyer.com" >> /tmp/filter/whitelist.hostname

#Яндекс в белый список
echo "ya.ru
www.ya.ru
yandex.ru
ya.ru
www.yandex.ru
yastatic.net
avatars.mds.yandex.net
mds.yandex.net
yandex.net
favicon.yandex.net
mc.yandex.ru
mail.yandex.ru
music.yandex.ru
market.yandex.ru
sso.passport.yandex.ru
passport.yandex.ru" >> /tmp/filter/whitelist.hostname
#Twitch
echo "www.twitch.tv
twitch.tv" >> /tmp/filter/whitelist.hostname
#
#Twitter
echo "twitter.com
www.twitter.com
x.com" >> /tmp/filter/whitelist.hostname
#
#Google
echo "google.com
google.ru
www.google.com
www.google.ru" >> /tmp/filter/whitelist.hostname
#
#MTS
echo "api.a.mts.ru" >> /tmp/filter/whitelist.hostname
#
#Ozon
echo "www.ozon.ru
ozon.ru
finance.ozon.ru
ozone.ru
ozonusercontent.com" >> /tmp/filter/whitelist.hostname
#Schakal white list
echo "ad.admitad.com
s.click.aliexpress.com
r.mradx.net
clck.ru
sba.yandex.net
mtalk.google.com
firebaseinstallations.googleapis.com
api.recsys.opera.com
news.opera-api.com
thumbnails.opera.com
news.opera-api.com
t.paypal.com
sessions.bugsnag.com
www.googletagmanager.com
www.google-analytics.com
ssl.google-analytics.com
stats.g.doubleclick.net
firebaseremoteconfig.googleapis.com
s.youtube.com
www.youtube-nocookie.com
youtube-nocookie.com
firebaseinstallations.googleapis.com
firebaseremoteconfig.googleapis.com
mc.yandex.ru
sbbe.group-ib.ru
firebaseremoteconfig.googleapis.com
firebaseinstallations.googleapis.com
firebase-settings.crashlytics.com
stat.online.sberbank.ru
report.appmetrica.yandex.net
top-fwz1.mail.ru
rs.mail.ru
firebaseremoteconfig.googleapis.com
mc.yandex.ru
push.yandex.com
startup.mobile.yandex.net
graph.instagram.com
html-load.com
rose.ixbt.com
pagead2.googlesyndication.com
www.googletagmanager.com
wurfl.io
pagead.l.doubleclick.net
www.googleadservices.com
googleadapis.l.google.com
ads.adfox.ru
mc.yandex.ru" >> /tmp/filter/whitelist.hostname
###
###
#Чистим от киррилитиcческих доменов
sed -i '/[А-Я]/d' /tmp/filter/whitelist.hostname
sed -i '/[а-я]/d' /tmp/filter/whitelist.hostname
#sed -i 's/^ *//g' /tmp/filter/whitelist.hostname
sed -i 's/ //g' /tmp/filter/whitelist.hostname #Чистим от пробелов
sed -i '/\$/d' /tmp/filter/whitelist.hostname
sed -i '1d' /tmp/filter/whitelist.hostname
sort /tmp/filter/whitelist.hostname -T /root/ | uniq | sponge /tmp/filter/whitelist.hostname
sed -i '1d' /tmp/filter/whitelist.hostname
echo "Сливаем списки, которые в HOME... (Если есть и не пусты)"
if [[ -f /home/"$USERNAME"/whitelist.txt ]]; then
    if [[ -s /home/"$USERNAME"/whitelist.txt ]]; then
        cat /home/"$USERNAME"/whitelist.txt >> /tmp/filter/whitelist.hostname
    else
        echo "Файл пустой!"
    fi
else
    echo "Внимание файла не существует(белый список)...!"
fi

if [[ -f /home/"$USERNAME"/blacklist.txt ]]; then
    if [[ -s /home/"$USERNAME"/blacklist.txt ]]; then
        cat /home/"$USERNAME"/blacklist.txt >> /tmp/filter/unbound.hostname
    else
        echo "Файл пустой!"
    fi
else
    echo "Внимание файла не существует(черный список)...!"
fi
###
echo ""
echo "Сортируем списки..."
sort /tmp/filter/unbound.hostname -T /root/ | uniq | sponge /tmp/filter/unbound.hostname.sort
mv /tmp/filter/unbound.hostname.sort /tmp/filter/unbound.hostname
dos2unix /tmp/filter/unbound.hostname
sed -i 's/ /\n/g' /tmp/filter/unbound.hostname
sed -i 's/ //g' /tmp/filter/unbound.hostname
sed -i -r '/^\s*$/d' /tmp/filter/unbound.hostname
sed -i 's/[<>]//g' /tmp/filter/unbound.hostname
sed -i 's/^https\?:\/\///g' /tmp/filter/unbound.hostname
sed -i '/[А-Я]/d' /tmp/filter/unbound.hostname
sed -i '/[а-я]/d' /tmp/filter/unbound.hostname
sed -i 's/\t//g' /tmp/filter/unbound.hostname
sed -i '/^!/d' /tmp/filter/unbound.hostname
sed -i '/^!!/d' /tmp/filter/unbound.hostname
sed -i '/\$/d' /tmp/filter/unbound.hostname
sed -i '1d' /tmp/filter/unbound.hostname

sort /tmp/filter/whitelist.hostname -T /root/ | uniq | sponge /tmp/filter/whitelist.hostname.sort
mv /tmp/filter/whitelist.hostname.sort /tmp/filter/whitelist.hostname
dos2unix /tmp/filter/whitelist.hostname
sed -i 's/ /\n/g' /tmp/filter/whitelist.hostname
sed -i 's/ //g' /tmp/filter/whitelist.hostname
sed -i -r '/^\s*$/d' /tmp/filter/whitelist.hostname
sed -i 's/[<>]//g' /tmp/filter/whitelist.hostname
sed -i 's/^https\?:\/\///g' /tmp/filter/whitelist.hostname
sed -i '/[А-Я]/d' /tmp/filter/whitelist.hostname
sed -i '/[а-я]/d' /tmp/filter/whitelist.hostname
sed -i 's/\t//g' /tmp/filter/whitelist.hostname
sed -i '/^!/d' /tmp/filter/whitelist.hostname
sed -i '/^!!/d' /tmp/filter/whitelist.hostname
sed -i '/\$/d' /tmp/filter/whitelist.hostname
sed -i '1d' /tmp/filter/whitelist.hostname

echo ""
echo "Сливаем два списка предварительно отсортируем их в новый список идёт только разница"
/usr/bin/diff -y -B /tmp/filter/unbound.hostname /tmp/filter/whitelist.hostname | grep -iE '(<)' | sed 's/[<>]//g' | sed 's/ //g' > /tmp/01_unbound_filters.hostname
#comm -23 /tmp/filter/unbound.hostname /tmp/filter/whitelist.hostname > /tmp/01_unbound_filters.hostname
sort /tmp/01_unbound_filters.hostname -T /root/ | uniq | sponge /tmp/01_unbound_filters.hostname
dos2unix /tmp/01_unbound_filters.hostname
sed -i 's/ /\n/g' /tmp/01_unbound_filters.hostname
sed -i 's/ //g' /tmp/01_unbound_filters.hostname
sed -i -r '/^\s*$/d' /tmp/01_unbound_filters.hostname
sed -i 's/[<>]//g' /tmp/01_unbound_filters.hostname
sed -i 's/^https\?:\/\///g' /tmp/01_unbound_filters.hostname
sed -i '/[А-Я]/d' /tmp/01_unbound_filters.hostname
sed -i '/[а-я]/d' /tmp/01_unbound_filters.hostname
sed -i 's/\t//g' /tmp/01_unbound_filters.hostname
sed -i '/^!/d' /tmp/01_unbound_filters.hostname
sed -i '/^!!/d' /tmp/01_unbound_filters.hostname
sed -i '1d' /tmp/01_unbound_filters.hostname
echo ""
#
sed -i '/twitter.com/d' /tmp/01_unbound_filters.hostname
sed -i '/x.com/d' /tmp/01_unbound_filters.hostname
sed -i '/twitch.tv/d' /tmp/01_unbound_filters.hostname
sed -i '/twitch.com/d' /tmp/01_unbound_filters.hostname
sed -i '/twitchcdn.net/d' /tmp/01_unbound_filters.hostname
sed -i '/fastly.net/d' /tmp/01_unbound_filters.hostname
sed -i '/windows.net/d' /tmp/01_unbound_filters.hostname
sed -i '/cloudflareinsights.com/d' /tmp/01_unbound_filters.hostname
sed -i '/ttvnw.net/d' /tmp/01_unbound_filters.hostname
sed -i '/tinkoff.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/ltkarta.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/tricolor.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/^digiseller.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/^api.digiseller.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/googlevideo.com/d' /tmp/01_unbound_filters.hostname
sed -i '/avito.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/z-lib.id/d' /tmp/01_unbound_filters.hostname
sed -i '/osm.wifly.net/d' /tmp/01_unbound_filters.hostname
sed -i '/wifly.net/d' /tmp/01_unbound_filters.hostname
sed -i '/xhcdn.com/d' /tmp/01_unbound_filters.hostname
##CDN
sed -i '/akamaihd.net/d' /tmp/01_unbound_filters.hostname
sed -i '/akamaized.net/d' /tmp/01_unbound_filters.hostname
sed -i '/amazonaws.com/d' /tmp/01_unbound_filters.hostname
sed -i '/mixpanel.com/d' /tmp/01_unbound_filters.hostname
sed -i '/avataaars.io/d' /tmp/01_unbound_filters.hostname
sed -i '/azureedge.net/d' /tmp/01_unbound_filters.hostname
sed -i '/bootstrapcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/bugsnag.com/d' /tmp/01_unbound_filters.hostname
sed -i '/changelog.com/d' /tmp/01_unbound_filters.hostname
sed -i '/paddle.com/d' /tmp/01_unbound_filters.hostname
sed -i '/polyfill.com/d' /tmp/01_unbound_filters.hostname
sed -i '/polyfill.io/d' /tmp/01_unbound_filters.hostname
sed -i '/cloudflare.com/d' /tmp/01_unbound_filters.hostname
sed -i '/cloudfront.net/d' /tmp/01_unbound_filters.hostname
sed -i '/jquery.com/d' /tmp/01_unbound_filters.hostname
sed -i '/edgesuite.net/d' /tmp/01_unbound_filters.hostname
sed -i '/devmate.com/d' /tmp/01_unbound_filters.hostname
sed -i '/dropboxstatic.com/d' /tmp/01_unbound_filters.hostname
sed -i '/fastly.net/d' /tmp/01_unbound_filters.hostname
sed -i '/fbcdn.net/d' /tmp/01_unbound_filters.hostname
sed -i '/soundcloud.com/d' /tmp/01_unbound_filters.hostname
sed -i '/fiplabcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/firebaseio.com/d' /tmp/01_unbound_filters.hostname
sed -i '/googleapis.com/d' /tmp/01_unbound_filters.hostname
sed -i '/gstatic.com/d' /tmp/01_unbound_filters.hostname
sed -i '/gfx.ms/d' /tmp/01_unbound_filters.hostname
sed -i '/ggpht.com/d' /tmp/01_unbound_filters.hostname
sed -i '/ghbtns.com/d' /tmp/01_unbound_filters.hostname
sed -i '/githubusercontent.com/d' /tmp/01_unbound_filters.hostname
sed -i '/googleusercontent.com/d' /tmp/01_unbound_filters.hostname
sed -i '/googlevideo.com/d' /tmp/01_unbound_filters.hostname
sed -i '/gravatar.com/d' /tmp/01_unbound_filters.hostname
sed -i '/gvt1.com/d' /tmp/01_unbound_filters.hostname
sed -i '/helpscout.net/d' /tmp/01_unbound_filters.hostname
sed -i '/hockeyapp.net/d' /tmp/01_unbound_filters.hostname
sed -i '/icloud-content.com/d' /tmp/01_unbound_filters.hostname
sed -i '/images-amazon.com/d' /tmp/01_unbound_filters.hostname
sed -i '/imgix.net/d' /tmp/01_unbound_filters.hostname
sed -i '/intercom.io/d' /tmp/01_unbound_filters.hostname
sed -i '/intercomassets.com/d' /tmp/01_unbound_filters.hostname
sed -i '/intercomcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/kxcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/local.adguard.com/d' /tmp/01_unbound_filters.hostname
sed -i '/adguard.com/d' /tmp/01_unbound_filters.hostname
sed -i '/loggly.com/d' /tmp/01_unbound_filters.hostname
sed -i '/media-amazon.com/d' /tmp/01_unbound_filters.hostname
sed -i '/msecnd.net/d' /tmp/01_unbound_filters.hostname
sed -i '/msedge.net/d' /tmp/01_unbound_filters.hostname
sed -i '/notion-static.com/d' /tmp/01_unbound_filters.hostname
sed -i '/paddle.com/d' /tmp/01_unbound_filters.hostname
sed -i '/paddleapi.com/d' /tmp/01_unbound_filters.hostname
sed -i '/pscdn.co/d' /tmp/01_unbound_filters.hostname
sed -i '/pusher.com/d' /tmp/01_unbound_filters.hostname
sed -i '/query.yahoo.com/d' /tmp/01_unbound_filters.hostname
sed -i '/rackcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/raw.github.com/d' /tmp/01_unbound_filters.hostname
sed -i '/raw.githubusercontent.com/d' /tmp/01_unbound_filters.hostname
sed -i '/raygun.io/d' /tmp/01_unbound_filters.hostname
sed -i '/replies.io/d' /tmp/01_unbound_filters.hostname
sed -i '/res.cloudinary.com/d' /tmp/01_unbound_filters.hostname
sed -i '/scdn.co/d' /tmp/01_unbound_filters.hostname
sed -i '/sentry.io/d' /tmp/01_unbound_filters.hostname
sed -i '/sndcdn.com/d' /tmp/01_unbound_filters.hostname
sed -i '/ssl-images-amazon.com/d' /tmp/01_unbound_filters.hostname
sed -i '/statuspage.io/d' /tmp/01_unbound_filters.hostname
sed -i '/tinyfac.es/d' /tmp/01_unbound_filters.hostname
sed -i '/twimg.com/d' /tmp/01_unbound_filters.hostname
sed -i '/typekit.net/d' /tmp/01_unbound_filters.hostname
sed -i '/vsassets.io/d' /tmp/01_unbound_filters.hostname
sed -i '/vscode-update.azurewebsites.net/d' /tmp/01_unbound_filters.hostname
sed -i '/ytimg.com/d' /tmp/01_unbound_filters.hostname
sed -i '/^yastatic.net/d' /tmp/01_unbound_filters.hostname
sed -i '/aviasales\.ru/d' /tmp/01_unbound_filters.hostname
##
sed -i '/ipv6-test\.com/d' /tmp/01_unbound_filters.hostname
sed -i '/cse\.google\.com/d' /tmp/01_unbound_filters.hostname
sed -i '/securitylab\.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/irr\.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/spb\.ru/d' /tmp/01_unbound_filters.hostname
sed -i '/||spb.ru\^/d' /tmp/01_unbound_filters.hostname
sed -i '/spb/d' /tmp/01_unbound_filters.hostname
sed -i '/github.com/d' /tmp/01_unbound_filters.hostname
#

cat /tmp/01_unbound_filters.hostname | sort -T /root/ | uniq | awk -F="" '{ print "0.0.0.0" " " $1}' > /etc/dnsmasq.d/hosts

echo ""
echo "Удаление загруженых листов..."
if [[ -d /tmp/filter ]]; then
    delele_dir
fi
echo ""

if [[ "$auto_reboot_service_after_upd_list" == "Y" ]] || [[ "$auto_reboot_service_after_upd_list" == "y" ]]; then
    echo -e "\e[1;33mАвтоматическая перезагрузка сервиса... \033[0m"
    systemctl -q restart dnsmasq.service
    clear && echo "" && systemctl -q status dnsmasq.service
else
    echo -e "\e[1;33mНе забудьте перезагрузить сервис dnsmasq вручную!!!! \033[0m"
fi
cp -vf /tmp/01_unbound_filters.hostname ${HOME_GITHUB}/templates/dnsmasq/dnsmasq.d/domains.host
cp -vf /etc/dnsmasq.d/hosts ${HOME_GITHUB}/templates/dnsmasq/dnsmasq.d/
count_line=$(cat ${HOME_GITHUB}/templates/dnsmasq/dnsmasq.d/domains.host | wc -l)
print_date=$(date -u +"%d %b %Y %H:%M UTC")
echo -e "!Title: Users filter you-oops-dev\n!Last modified: ${print_date}\n!Expires: 1 hours\n!Records: ${count_line}\n" | tee ${HOME_GITHUB}/ublock_origin_hosts.txt
cat /etc/dnsmasq.d/hosts >> ${HOME_GITHUB}/ublock_origin_hosts.txt
#Create list for Adblock Plus (cromite) and uBlock Origin
wget -4q -nv -O - https://raw.githubusercontent.com/eEIi0A5L/adblock_filter/master/youtube_wo_tonikaku_filter.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' > ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/kbinani/adblock-youtube-ads/master/signed.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://easylist-downloads.adblockplus.org/ruadlist+easylist.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/DandelionSprout/adfilt/master/AdGuard%20Home%20Compilation%20List/AdGuardHomeCompilationList.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/badblock_lite.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/ruadlist.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/uazo/cromite/refs/heads/master/tools/filters/experimental-cromite-filters.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/abp-filters-anti-cv.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/badmojr-1Hosts-master-Pro-adblock.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/global-filters.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/fanboy-notifications.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.cromite.org/filters/easyprivacy.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://www.i-dont-care-about-cookies.eu/abp/ | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://easylist-downloads.adblockplus.org/ruadlist-minified.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://gitlab.com/eyeo/anti-cv/abp-filters-anti-cv/-/raw/master/russian.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/pafnuty/onlineConsultantBlocker/master/online-consultant.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/duskwuff/syndicationblock/master/filters.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/DandelionSprout/adfilt/master/AntiMV3List.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/DandelionSprout/adfilt/master/stayingonbrowser/Staying%20On%20The%20Phone%20Browser | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/Spam404/lists/master/adblock-list.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://mkb2091.github.io/blockconvert/output/adblock.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://secure.fanboy.co.nz/fanboy-cookiemonster.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/caffeinewriter/DontPushMe/master/filterlist.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/Hubird-au/Adversity/master/Adversity.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/T4Tea/ADPMobileFilter/master/ADPMobileFilter.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
wget -4q -nv -O - https://raw.githubusercontent.com/Zalexanninev15/NoADS_RU/refs/heads/main/ads_list.txt | sed '/!/d' | sed '/\[Adblock Plus/d' | sed 's/ //g' | sed -r '/^\s*$/d' >> ${HOME_GITHUB}/ublock_origin_abp.temp
#
#Fixing list
sed -i '/\?action=opensearch/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/www.google.com\/complete/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/google.com\/complete/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/www.google.ru\/complete/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/google.ru\/complete/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/youtube\.com\/api\/stats/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/www\.youtube\.com\/api\/stats/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||www\.youtube.com\/api\/stats/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||youtube.com\/api\/stats/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||www\.youtube.com\/api\/stats\//d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||youtube.com\/api\/stats\//d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/dnsleaktest\.com/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/\/matomo\.js/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/cse\.google\.com/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||cdn2.ozone.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||xapi.ozon.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||ir-3.ozone.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||5ka.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||uptodown.com\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||maxmind.com\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||nowa.cc\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||toptracker.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||tapochek.net\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||hidemy.name\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||ir.ozone.ru\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||sourceforge.net\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||sourceforge.io\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||ipv6-test.com\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||github.com\^/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||ytimg\.com\/generate_204/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/||i\.ytimg\.com\/generate_204/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/PHPSESSID/d' ${HOME_GITHUB}/ublock_origin_abp.temp
sed -i '/\/matomo.php/d' ${HOME_GITHUB}/ublock_origin_abp.temp
#
sort -T /root/ ${HOME_GITHUB}/ublock_origin_abp.temp | uniq > ${HOME_GITHUB}/ublock_origin_abp.temp.2 && mv -f ${HOME_GITHUB}/ublock_origin_abp.temp.2 ${HOME_GITHUB}/ublock_origin_abp.temp

count_line=$(cat ${HOME_GITHUB}/ublock_origin_abp.temp | wc -l)
print_date=$(date -u +"%d %b %Y %H:%M UTC")
echo -e "!Title: Users filter you-oops-dev for ubo and abp\n!Last modified: ${print_date}\n!Expires: 1 hours\n!Records: ${count_line}\n" | tee ${HOME_GITHUB}/ublock_origin_abp.txt
cat ${HOME_GITHUB}/ublock_origin_abp.temp >> ${HOME_GITHUB}/ublock_origin_abp.txt
rm -f ${HOME_GITHUB}/ublock_origin_abp.temp
exit 0
