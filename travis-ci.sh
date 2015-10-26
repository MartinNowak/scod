#!/usr/bin/env bash

set -eo pipefail

./assets/compile.sh
if [ ! -z "$(git status -uno -- public | grep modified)" ]; then
    echo 'Forgot to precompile assets?'
    exit 1
fi
dub build --compiler=${DC:-dmd}
dub --compiler=${DC:-dmd} -- serve-html test/test.json &
PID=$!
cleanup() { kill $PID; }
trap cleanup EXIT

npm install phantomcss -q
if ! ./node_modules/phantomcss/node_modules/.bin/casperjs test test/test.js ; then
    # upload failing screenshots
    cd test/screenshots
    for img in *.{diff,fail}.png; do
        ARGS="$ARGS -F image=@$img"
    done
    ARGS="$ARGS -F build_id=$TRAVIS_BUILD_ID"
    curl -fsSL https://ddox-test-uploads.herokuapp.com $ARGS
    exit 1
fi
