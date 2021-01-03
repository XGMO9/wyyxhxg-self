#!/bin/sh
for dir in $(ls -d */*)
do
  echo "$dir" && cd "$dir" && ffmpeg -i video.m4s -i audio.m4s -codec copy video.mp4 && cd .. && cd ..
done
