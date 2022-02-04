#!/bin/bash

COUNT=0

if { set -C; 2>/dev/null >/var/tmp/rtsc.lck; }; then
        trap "rm -f /var/tmp/rtsc.*" EXIT
else
	echo "rtsc.data already exists. Exiting." >> /var/tmp/$(date +%Y%M%D%H%M)telegraf.rtsc.fail
        exit
fi

if [ -s /var/tmp/rtsc.data ]; then
	rm -f /var/tmp/rtsc.data
fi

while true; do
	if [ -s /var/tmp/rtsc.data ]; then
		cat /var/tmp/rtsc.data | sed -n 'p;n' | tr '\n\r' ',' | sed 's/,,/,/g' | sed 's/.$//'
		echo ""
		cat /var/tmp/rtsc.data | sed -n 'n;p' | tr '\n\r' ',' | sed 's/,,/,/g' | sed 's/.$//'
		exit 0
	else
		curl -s "https://www.ercot.com/content/cdr/html/real_time_system_conditions.html" | sed '0,/^<tbody>/d' | sed 's/<[^>]*>//g' | sed 's/Frequency//g' | sed 's/Real-Time\ Data//g' | sed 's/DC\ Tie\ Flows//g' | sed '/^[[:space:]]*$/d' | sed 's/^[ \t]*//' | sed 's/Current/Frequency/1' >> /var/tmp/rtsc.data
	fi
	((COUNT=COUNT+1))
	sleep 1
	if [ $COUNT -eq 10 ]; then
		exit 1
	fi
done
