#!/bin/bash
set -ex

rm -rf dest || exit 0;

mkdir -p dest

# compile JS using Elm and minify with uglify
elm make src/Main.elm --yes --output dest/assets/elm.js
uglifyjs dest/assets/elm.js -c warnings=false -m --screw-ie8 -o dest/assets/elm.min.js
rm dest/assets/elm.js

# replace elm.js from debug to prod
sed 's/\/_compile\/src\/Main\.elm/assets\/elm\.min\.js/g' index.html > dest/index.html

# publish to itch.io
./butler push dest unsoundscapes/flatris:html