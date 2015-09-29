#!/bin/bash

mkdir -p public/css
cat assets/css/{normalize,skeleton,tomorrow,scod}.css | yuglify --terminal --type css > public/css/style.min.css
mkdir -p public/js
cat assets/js/{prettify,scod}.js | yuglify --terminal --type js > public/js/script.min.js
