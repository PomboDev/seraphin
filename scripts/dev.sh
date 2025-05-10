#!/bin/sh

set -e

if [ ! -d "roblox_packages" ]; then
    pesde install
fi

rm -rf out/
mkdir -p out/

rojo sourcemap default.project.json -o sourcemap.json
ROBLOX_DEV=false darklua process --config .darklua.json src/ out/

rojo serve build.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
    & ROBLOX_DEV=true darklua process --config .darklua.json --watch src/ out/ \

