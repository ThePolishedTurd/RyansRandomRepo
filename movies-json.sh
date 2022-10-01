#!/bin/bash

# this is just a quick and dirty script to look at a directory full of movies and output a json.
# as a result this requires that your movies are all formatted properly. 
# The script could be improved by looking to see if the end of line is coming and remove the last comma
# and only look for the last 4 numbers to use as the year. right now its looking at whatever first 4 show up
# which presents a problem with movies like bladerunner 2049 or fantasia 2000. I see it as minor and just manually clean those up.
# movies should follow standard Plex formatting ex: "The Fifth Element (1997).mp4"

moviedir=/someplace/Movies/ # directory where movies are stored.
file=movielist.txt

ls -1 $moviedir > $file     # make a file we can work out of
sed -i -s 's/\....//g' $file  # removes the file extensions

# start printing out the json file to stdout
printf "[\n" 
while read -r line; do # reads the file one line at a time.
	year="$( echo $line | grep -o --color=never -E '[0-9]{4}')"  # gets the release year of the movie from the filename
	title="$( echo $line | grep -o --color=never -E '^.*\ ' | sed 's/.$//g' )"  # prints out the name of the movie without the year
	printf "   {\n      \"title\": \"$title\",\n      \"year\": \"$year\"\n   },\n"  # spit it out
done <$file
printf "]\n"

rm movielist.txt # cleanup and exit
exit 0
