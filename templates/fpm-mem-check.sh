#!/usr/bin/sh
# Check free memory, if lower than 6%, restart PHP-FPM
# http://unix.stackexchange.com/questions/152299/
#
# Run it with cron:
# $crontab -e
# * * * * * bash /srv/scripts/fpm-mem-check.sh >/dev/null 2>&1
curMemCheck=`free | awk '/Mem/{printf("%.0f"), $3/$2*100}'`
showCurMem=`free | awk '/Mem/{printf("used: %.2f%"), $3/$2*100} /buffers\/cache/{printf(", buffers: %.2f%"), $4/($3+$4)*100} /Swap/{printf(", swap: %.2f%"), $3/$2*100}'`
hosnName=`hostname`

if (($curMemCheck > 90))
then
  systemctl reload php-fpm
  curl -X POST --data-urlencode 'payload={"channel": "{{ php_slack_channel }}", "username": "{{ php_slack_username }}", "attachments": [{"color": "#ff0000", "fields": [{"title": "Server Details", "value":"'"$showCurMem"'", "short": false}]}], "text": "Low memory on '"$hosnName"'! reloading PHP-FPM….", "icon_emoji": ":rotating_light:"}' {{ php_slack_hook }}
fi
