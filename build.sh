#!/bin/sh

version=$(grep 'version=' module.prop | awk -F '=' '{print $2}' | sed 's/ (.*//')

if [ "$isAlpha" = true ]; then
    short_hash=$(git rev-parse --short=7 HEAD)
    filename="Surfing_alpha_${short_hash}.zip"
else
    filename="Surfing_${version}_release.zip"
fi

cd Surfingtile || exit 1
zip -r -o -X -ll ../Surfingtile.zip ./*
cd ..

zip -r -o -X -ll "$filename" ./ \
    -x 'Surfingtile/*' \
    -x '.git/*' \
    -x '.github/*' \
    -x 'folder/*' \
    -x 'build.sh' \
    -x 'Surfing.json'