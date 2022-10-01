#!/bin/bash

# this is just a quick and dirty script to look at a directory full of movies and output a json.
# as a result this requires that your movies are all formatted properly. 
# movies should follow standard Plex formatting ex: "The Fifth Element (1997).mp4"

moviedir=/someplace/Movies/ # directory where movies are stored.
file=movielist.txt
out=output.json

ls -1 $moviedir > $file     # make a file we can work out of
sed -i -s 's/\....$//g' $file  # removes the file extensions

# start printing out the json file to stdout
printf "[\n" >$out
while read -r line; do # reads the file one line at a time.
	year="$( echo $line | grep -o --color=never -E '\S[0-9]{4}\S')"  # gets the release year of the movie from the filename
	title="$( echo $line | grep -o --color=never -E '^.*\ ' | sed 's/.$//g' )"  # prints out the name of the movie without the year
	printf "   {\n      \"title\": \"$title\",\n      \"year\": \"$year\"\n   },\n" >>$out # spit it out
done <$file
printf "]\n" >>$out
sed -i 'x; ${s/,//;p;x}' $out
sed -i '1d' $out
rm movielist.txt # cleanup and exit
exit 0
