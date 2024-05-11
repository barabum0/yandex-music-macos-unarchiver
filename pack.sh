#!/bin/bash

if [ -z "$1" ]; then
    echo "Pass original .app folder as an argument"
    return 1
fi

if [ ! -z "$2" ]; then
    echo "Script accepts only one argument"
    return 1
fi

asar p app "$1/Contents/Resources/app.asar"

output=$("$1/Contents/MacOS/Яндекс Музыка" 2>&1)
if [ $? != 133 ]; then
    return 1
fi

bad_hash=$(echo $output | grep -oE "vs (.+)\)$" | sed 's/vs \(.*\))/\1/')
good_hash=$(echo $output | grep -oE " \((.+)vs " | sed 's/ [\(]\(.*\) vs /\1/')

sed -i "" "s|$good_hash|$bad_hash|g" "$1/Contents/Info.plist"

sed -i "" "s|https://music-desktop-application.s3.yandex.net/stable/|http://localhost:8080|g" "$1/Contents/Resources/app-update.yml"

#cat "$1/Contents/Info.plist" | grep $good_hash