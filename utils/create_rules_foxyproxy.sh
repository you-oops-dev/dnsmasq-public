#!/usr/bin/bash
#
export LANG=en_US.UTF-8
export CHARSET=UTF-8
export NAME_ACCOUNT_GITHUB=you-oops-dev
#
export HOME_GITHUB=$(pwd)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${HOME_GITHUB}/utils
export SORT_PATH=/tmp/

cd $HOME_GITHUB/templates/foxyproxy
cp -fv ../sing-box/domain.txt ./
cp -fv ../sing-box/domain_wildcard.txt ./

jq -Rn '
  [ inputs | { 
      include: "include",
      type: "wildcard",
      title: "",
      pattern: ("*://" + .),
      active: true
    } ]
' < ../sing-box/domain.txt > foxyproxy.json

exit 0
