#!/bin/sh
for dir in $(ls -d */*)
do
  cd "$dir" && name=`cat ../entry.json | jq -r '.title'` && count=`cat ../entry.json | jq -r '.ep.index'`
  filename="$name"_"$count"
  ffmpeg -i video.m4s -i audio.m4s -codec copy $filename.mp4 && cd .. && cd ..
done