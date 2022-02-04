#!/bin/bash

# Sets how many times the script will try to download the webpage.
COUNT=0
RETRY=10
# Check if a lock file exists if it does then exit if not then create it. Also deletes the temporary data file we're working out of.
if { set -C; 2>/dev/null >/var/tmp/rtsc.lck; }; then
        trap "rm -f /var/tmp/rtsc.*" EXIT
else
	echo "rtsc.data already exists. $(date +%F-%H:%M)" >> /var/tmp/telegraf.rtsc.fail
        exit
fi

# Check if the data file exists if it does then delete it.
if [ -s /var/tmp/rtsc.data ]; then
	rm -f /var/tmp/rtsc.data
fi

# Main loop
while true; do
	# Check if rtsc.data exists and has something in it. If it doesn't then try to download the webpage.
	if [ -s /var/tmp/rtsc.data ]; then
		# Reads the partially parsed data that was downloaded, separates out the odd numbered lines and spits out the csv header.
		cat /var/tmp/rtsc.data | sed -n 'p;n' | tr '\n\r' ',' | sed 's/,,/,/g' | sed 's/.$//'
		# Prints a new line
		echo ""
		# Reads the partially parsed data that was downloaded, separates out the even numbered lines and spits out the csv data.
		cat /var/tmp/rtsc.data | sed -n 'n;p' | tr '\n\r' ',' | sed 's/,,/,/g' | sed 's/.$//'
		# Now that the data has been printed to stdout it can exit cleanly. This also calls the trap to delete our data and lock files.
		exit 0
	else
		# Download the webpage and parse out only the data we want from it.
		curl -s "https://www.ercot.com/content/cdr/html/real_time_system_conditions.html" | sed '0,/^<tbody>/d' | sed 's/<[^>]*>//g' | sed 's/Frequency//g' | sed 's/Real-Time\ Data//g' | sed 's/DC\ Tie\ Flows//g' | sed '/^[[:space:]]*$/d' | sed 's/^[ \t]*//' | sed 's/Current/Frequency/1' >> /var/tmp/rtsc.data
	fi
	# Increment the retry counter.
	((COUNT=COUNT+1))
	sleep 1
	# Check if we have hit the max number of retries.
	if [ $COUNT -eq $RETRY ]; then
		exit 1
	fi
done
