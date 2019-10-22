#!/bin/bash

ROOT=http://www.colorcomputerarchive.com/coco/Disks/Games

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

while read -r name
do
  file=$(urldecode "$name")
  filename="./games/$file"
  url="$ROOT/$name"

  if [ ! -f "$filename" ]; then
    echo "Downloading $url to $filename"
    curl -L "$url" > "$filename"
  else
    echo "Skipping $filename"
  fi

done < "./games.dat"
