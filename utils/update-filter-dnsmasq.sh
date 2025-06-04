#!/usr/bin/env bash

auto_reboot_service_after_upd_list=y

if [ "$UID" -ne "0" ]; then
    echo -e "\n\e[0;33m[${0##*/}]\e[1;31m Error: \e[0;33mYOU MUST BE ROOT TO USE THIS!"
    echo -e "\e[0;35mTip: \e[0;33mPrecede your command with 'sudo'\e[0m\n"
    exit 1
fi
USERNAME=root
export HOME_GITHUB=$(pwd)

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

echo "Загрузка листа... Содержит домена вредоностных сайтов с вредоностным ПО..."
wget -nv -4 -O /tmp/filter/APT1Rep.hostname https://v.firebog.net/hosts/APT1Rep.txt
echo ""

echo "Загрузка листа... Содержит домена вредоностных сайтов с вредоностным ПО..."
wget -nv -4 -O /tmp/filter/Spam404.hostname https://v.firebog.net/hosts/Spam404.txt
echo ""

echo "Загрузка листа... Содержит домена вредоностных сайтов с вредоностным ПО..."
wget -nv -4 -O /tmp/filter/JoeyLane.hostname https://v.firebog.net/hosts/JoeyLane.txt
echo ""

echo "Загрузка листа... Содержит домена трекеров"
wget -nv -4 -P /tmp/filter/ https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
sed -i '/vortex.data.microsoft.com/d; /vortex-win.data.microsoft.com/d' /tmp/filter/spy.txt
cat /tmp/filter/spy.txt | awk -F\# '$1!="" { print $1 ;}' | awk '{print $2}' > /tmp/filter/spy.hostname
echo ""

#echo "Загрузка список хостов TikTok (но не включаем его)"
#wget -nv -4 -P /tmp/filter/ https://raw.githubusercontent.com/d43m0nhLInt3r/socialblocklists/master/TikTok/tiktokblocklistWithoutRegex.txt
#cat /tmp/filter/tiktokblocklistWithoutRegex.txt | awk '{print $2}' > /tmp/filter/tiktok_block.hostname_off
#echo ""

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
cat /tmp/filter/GoodbyeAds-Ultra.txt | awk -F\# '$1!="" { print $1 ;}' | grep -i 0.0.0.0 | sed '/0.0.0.0 0.0.0.0/d' | awk '{print $2}' > /tmp/filter/GoodbyeAds-Ultra.hostname_off
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
cat /tmp/filter/wapclick_*.txt | awk -F\! '$1!="" { print $1 ;}' | sort -u | sed '1d'  > /tmp/filter/01_anti_wapclick.hostname
#echo ""

#Блокировка онлайн-казино
echo "Загрузка листа... Содержит домена онлайн-казино..."
#Azino
wget -4 -nv -O /tmp/filter/01_azino.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_all_bets_are_off__azino7_all
#1xbet
wget -4 -nv -O /tmp/filter/01_1xbet.txt https://raw.githubusercontent.com/mtxadmin/ublock/master/hosts/subdomains/_all_bets_are_off__1xbet_all
cat /tmp/filter/01_{azino,1xbet}.txt | awk -F\! '$1!="" { print $1 ;}' | sort -u | sed '1d' > /tmp/filter/01_casino.hostname
echo ""
echo "Блокировка рекламы"
wget -4 -nv -O /tmp/filter/RUAdListBitBlock.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListBitBlock.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock1.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListCounters.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock2.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RU-AdList.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock3.hostname https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/CountryCodesLists/Russia.txt
wget -4 -nv -O /tmp/filter/RUAdListBitBlock4.txt https://raw.githubusercontent.com/parseword/nolovia/master/skel/hosts-government-malware.txt
cat /tmp/filter/RUAdListBitBlock4.txt | sed '/#/d' | sed '/!/d' | sort | uniq > /tmp/filter/RUAdListBitBlock4.hostname
wget -4 -nv -O /tmp/filter/RUAdListBitBlock5.txt https://block.energized.pro/blu/formats/domains.txt
cat /tmp/filter/RUAdListBitBlock5.txt | sed '/#/d' | sed '/!/d' | sort | uniq > /tmp/filter/RUAdListBitBlock5.hostname
echo ""

echo "Объеденение несколько списков в один список..."
cat /tmp/filter/*.hostname > /tmp/filter/unbound.hostname
echo ""

echo -e "\e[1;33mПовторно чистим на всякий пожарный случай...\033[0m"
sed -i 's/^0.0.0.0//g' /tmp/filter/unbound.hostname
sed -i 's/^127.0.0.1//g' /tmp/filter/unbound.hostname
sed -i '/#/d' /tmp/filter/unbound.hostname
sed -i 's/<\/*[^>]*>//g' /tmp/filter/unbound.hostname
sed -i 's/^!//g' /tmp/filter/unbound.hostname
#Чистим от киррилитических доменов
sed -i '/[А-Я]/d' /tmp/filter/unbound.hostname
sed -i '/[а-я]/d' /tmp/filter/unbound.hostname
#
sed -i 's/^ *//g' /tmp/filter/unbound.hostname
sort /tmp/filter/unbound.hostname | uniq | sponge /tmp/filter/unbound.hostname

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
echo "report.appmetrica.yandex.net
yastatic.net
storage.mds.yandex.ru
" >> /tmp/filter/unbound.hostname
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
#######
sort /tmp/filter/unbound.hostname | uniq | sponge /tmp/filter/unbound.hostname

echo "Загрузка белого листа"
wget -4 -nv -O /tmp/filter/whitelist.hostname https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
echo ""

###
##Разблокировка
echo "Добавляем доп. свои хосты для разблокировки"
echo "piwik.opendesktop.org" >> /tmp/filter/whitelist.hostname #скачивание тем для KDE
echo "suggestqueries.google.com" >> /tmp/filter/whitelist.hostname #поисковые подсказки Google
echo "hl-img.peco.uodoo.com" >> /tmp/filter/whitelist.hostname #для работоспособности браузера UC Browser
echo "browser.cloud.ucweb.com" >> /tmp/filter/whitelist.hostname #для работоспособности браузера UC Browser
echo "gstaticadssl.l.google.com" >> /tmp/filter/whitelist.hostname #для корректной работы шрифтов от Google
echo "audio-ak-spotify-com.akamaized.net" >> /tmp/filter/whitelist.hostname #для корректного переключения Spotify на другое устройство
echo "stat.online.sberbank.ru" >> /tmp/filter/whitelist.hostname #для корректной работы приложения сбербанка
echo "rutracker.wiki" >> /tmp/filter/whitelist.hostname
echo "is.gd" >> /tmp/filter/whitelist.hostname #Для работы реферальной ссылки из канала в ТГ Free Steam
echo "secure.gravatar.com" >> /tmp/filter/whitelist.hostname #Для работы аватарок на GitLab
echo "googleadservices.com" >> /tmp/filter/whitelist.hostname
echo "miru.mobi" >> /tmp/filter/whitelist.hostname
echo "static.wikia.nocookie.net" >> /tmp/filter/whitelist.hostname
echo "gstatic.com" >> /tmp/filter/whitelist.hostname
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
###
#Чистим от киррилитических доменов
sed -i '/[А-Я]/d' /tmp/filter/whitelist.hostname
sed -i '/[а-я]/d' /tmp/filter/whitelist.hostname
#
sed -i 's/ //g' /tmp/filter/whitelist.hostname #Чистим от пробелов

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
sort /tmp/filter/unbound.hostname | uniq | sponge /tmp/filter/unbound.hostname.sort
mv /tmp/filter/unbound.hostname.sort /tmp/filter/unbound.hostname

sort /tmp/filter/whitelist.hostname | uniq | sponge /tmp/filter/whitelist.hostname.sort
mv /tmp/filter/whitelist.hostname.sort /tmp/filter/whitelist.hostname
echo ""
echo "Сливаем два списка предварительно отсортируем их в новый список идёт только разница"
comm -23 /tmp/filter/unbound.hostname /tmp/filter/whitelist.hostname > /tmp/01_unbound_filters.hostname
echo ""

cat /tmp/01_unbound_filters.hostname | awk -F="" '{ print "0.0.0.0" " " $1}' > /etc/dnsmasq/dnsmasq.d/hosts

echo ""
echo "Удаление загруженых листов..."
if [[ -d /tmp/filter ]]; then
    delele_dir
fi
echo ""

if [[ "$auto_reboot_service_after_upd_list" == "Y" ]] || [[ "$auto_reboot_service_after_upd_list" == "y" ]]; then
    echo -e "\e[1;33mАвтоматическая перезагрузка сервиса... \033[0m"
    systemctl -q restart dnsmasq.service
    cp -v /tmp/01_unbound_filters.hostname ${HOME_GITHUB}/templates/dnsmasq/dnsmasq.d/domains.host
    cp -v /etc/dnsmasq/dnsmasq.d/hosts ${HOME_GITHUB}/templates/dnsmasq/dnsmasq.d/
    clear && echo "" && systemctl -q status dnsmasq.service
else
    echo -e "\e[1;33mНе забудьте перезагрузить сервис dnsmasq вручную!!!! \033[0m"
fi
exit 0
