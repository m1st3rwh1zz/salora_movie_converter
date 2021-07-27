#!/bin/bash

echo
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg is not installed!"
    echo
    exit
fi

function check_and_init () {
  valid=true
  if [ ! -d "./input" ]; then 
    mkdir -p "./input"
    echo "Subfolder 'input' is created!"
    valid=false
  fi
  if [ ! -d "./output" ]; then
    mkdir -p "./output"
    echo "Subfolder 'output' is created!"
    valid=false
  fi
  movie_counter=$(find ./input -maxdepth 2 -type f | wc -l)
  if [ "$movie_counter" -eq 0 ]; then
    echo "Put movies in 'input' folder or subfolder (max 1 subniveau) and run this script again"
    echo "Converted movies will be placed inside the 'output' folder or subfolder (will be created automatically when applicable)"
    valid=false
  fi
  if [ "$valid" = false ]; then
    echo
    exit
  fi
}

function create_folders () {
  input="$1"
  output="${input/input/output}"
  mkdir "$output"
}
export -f create_folders


function convert_movies () {
  input="$1"
  echo "Input : $input"
  output="${input/input/output}"
  output="${output%.*}.mp4"
  echo "Output: $output"
  echo
  ffmpeg -n -i "$input" -vf "scale=(iw*sar)*max(720/(iw*sar)\,405/ih):ih*max(720/(iw*sar)\,405/ih), crop=720:405" -c:v mpeg4 -q:v 8 -c:a mp3 -q:a 4 "$output"
  echo
}
export -f convert_movies

check_and_init

find ./input/* -maxdepth 1 -type d -exec /bin/bash -c 'create_folders "$0"' {} \;
find ./input/* -maxdepth 1 -type f -exec /bin/bash -c 'convert_movies "$0"' {} \;
