#!/bin/bash

set -eo pipefail

if ! npm install yuglify -q 2>install.err >/dev/null; then
    cat install.err 1>&2
fi
yuglify=node_modules/.bin/yuglify
mkdir -p public/css
cat assets/css/{normalize,skeleton,tomorrow,scod}.css | $yuglify --terminal --type css > public/css/style.min.css
mkdir -p public/js
cat assets/js/scod.js | $yuglify --terminal --type js > public/js/script.min.js
