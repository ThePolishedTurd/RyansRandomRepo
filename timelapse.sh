#!/bin/bash

## This script is for taking a directory of images and converting it into a video file. Images will be cropped and scaled before compiling.
## To use the script all images should be the same size and in their own directory with the only thing in that directory being the images themselves.


# Setup useful variables for easy access. 
# Scale is set for locked aspect ratio. Just set the width. 
# Crop is width x height + shift right + shift down
# files loads a list of all photos in the source directory into an array.
FPS=24
CROP='3000x1687+800+500'
SCALE='1920x'
SOURCE=/home/ryan/Pictures/temp
files=($(ls -x $SOURCE))

# Create a temp directory then loop through every photo in the source directory 
# Crop and scale each image before putting it in the temp directory to be compiled later.
mkdir temp
for i in "${files[@]}"
do
	convert $SOURCE$i -crop $CROP temp.jpg
	convert temp.jpg -resize $SCALE temp/$i.jpg
done

# Using ffmpeg we take every image from the temp directory and compile it into a video
# Then remove the temporary directory and image.
ffmpeg -framerate $FPS -pattern_type glob -i temp/'*.jpg' output.mp4
rm temp.jpg
rm -r temp/

exit 0
