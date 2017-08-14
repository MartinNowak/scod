#!/usr/bin/env bash

set -eo pipefail

./assets/compile.sh
if [ ! -z "$(git status -uno -- public | grep modified)" ]; then
    echo 'Forgot to precompile assets?'
    exit 1
fi
dub build --compiler=${DC:-dmd}
./scod serve-html test/test.json &
PID=$!
cleanup() { kill $PID; }
trap cleanup EXIT


bridgeip=$(ip -4 addr show dev docker0 | sed -n 's|.*inet \(.*\)/.*|\1|p')
if ! docker run --rm --env SCOD_ADDR="http://$bridgeip:8080" \
     --volume=$PWD/test:/usr/src/app/test martinnowak/phantomcss-tester test test/test.js; then
    # upload failing screenshots
    cd test/screenshots
    for img in *.{diff,fail}.png; do
        ARGS="$ARGS -F name=@$img"
    done
    curl -fsSL https://img.vim-cn.com/ $ARGS
    exit 1
fi
