#!/bin/sh
for dir in $(ls -d */)
do
  if [ -d "$dir"/.git ]; then
    echo "$dir" && cd "$dir" && git pull && cd ..
  fi
done