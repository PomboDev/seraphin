#!/bin/sh

set -e

if [ ! -d "roblox_packages" ]; then
    pesde install
fi

rojo sourcemap default.project.json -o sourcemap.json
curl -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua

luau-lsp analyze --definitions=globalTypes.d.lua --base-luaurc=src/.luaurc \
    --sourcemap=sourcemap.json --settings=.vscode/settings.json \
    --no-strict-dm-types --ignore Packages/**/*.lua --ignore Packages/**/*.luau \
    src/
