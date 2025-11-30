#!/usr/bin/bash
# Depends for Ubuntu\Debian packages dnsmasq ipset ipset-persistent iptables iptables-persistent
#
export LANG=en_US.UTF-8
export CHARSET=UTF-8
export THRESHOLDv4="1/4"
export IP2NET_PREFIX_LENGTH="10-24"
export NAME_ACCOUNT_GITHUB=you-oops-dev
export ACCOUNT_NAME=herrbischoff
export TYPE=ipv4
export Mat1RX_count=10000000
#
export HOME_GITHUB=$(pwd)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${HOME_GITHUB}/utils
#echo $PATH
echo -e "\e[1;33mPhase 2...\033[0m"
echo "Download unmerge list for bad_static set"
cat templates/ipset/delete_ip_bad.txt > /tmp/ru.txt
#curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/main/rostelecom/${TYPE}_merged.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/main/yandex/${TYPE}_merged.txt https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/main/vkontakte/${TYPE}_merged.txt | sudo sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -T /root/ >> /tmp/ru.txt
#curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/country-ip-blocks-unmerged/refs/heads/main/${TYPE}/unmerge_ru.txt.zst | zstd -d >> /tmp/ru.txt
sudo sort /tmp/ru.txt -T /root/ -h | uniq | sponge /tmp/ru.txt
#cat /tmp/ru.txt | ip2net --v4-threshold=${THRESHOLDv4} --prefix-length=${IP2NET_PREFIX_LENGTH} > /tmp/bad_static_merge
python utils/merge_Mat1RX.py -c ${Mat1RX_count} --source=/tmp/ru.txt > /tmp/bad_static_merge
sudo sort -h /tmp/bad_static_merge -T /root/ | uniq | sponge /tmp/bad_static_merge
rm -fv /tmp/*.txt /tmp/unblock_ipset.conf /tmp/unblock_nftset.conf && mv -fv /tmp/bad_static_merge /tmp/bad_static_merge.txt
echo "Download merge list for unblock_static set"
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/discord/ipv4_smart.txt > /tmp/unblock_static.txt
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/cloudflare/ipv4_smart.txt >> /tmp/unblock_static.txt
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/telegram/ipv4_smart.txt >> /tmp/unblock_static.txt
curl --max-time 30 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/${NAME_ACCOUNT_GITHUB}/ipranges/refs/heads/main/meta/ipv4_smart.txt >> /tmp/unblock_static.txt
#...
sudo sort /tmp/unblock_static.txt -T /root/ | uniq | sponge /tmp/unblock_static.txt

ls -lhs /tmp/

echo -e "\e[1;33mPhase 3...\033[0m"
mkdir -pv /tmp/ipset/
echo "Create bad static"
for bad in $(cat /tmp/bad_static_merge.txt); do sudo ipset -A bad_static "$bad";done
rm -fv /tmp/bad_static_merge.txt
echo "Save in config bad_static..."
sudo ipset -S bad_static > /tmp/ipset/bad_static.conf
sudo ipset -F bad_static
echo "Create unblock static"
for unblock in $(cat /tmp/unblock_static.txt); do sudo ipset -A unblock_static "$unblock";done
rm -fv /tmp/unblock_static.txt
echo "Save in config unblock_static..."
sudo ipset -S unblock_static > /tmp/ipset/unblock_static.conf
sudo ipset -F unblock_static
mv -fv /tmp/ipset/*.conf templates/ipset/
find ${HOME_GITHUB} -type f -name "*.conf.zst" -delete
echo "Compress ipset config..."
cat templates/ipset/bad_static.conf | zstd -o templates/ipset/bad_static.conf.zst
cat templates/ipset/unblock_static.conf | zstd -o templates/ipset/unblock_static.conf.zst
rm -fv templates/ipset/*.conf
