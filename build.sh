#!/bin/sh

isAlpha="${isAlpha:-false}"

CORE_DST="box_bll/bin/clash"
CORE_TMP="clash_core.gz"
MIHOMO_API="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
MIHOMO_BASE="https://github.com/MetaCubeX/mihomo/releases/download"
MIHOMO_NAME="mihomo-android-arm64-v8"

ZASH_API="https://api.github.com/repos/Zephyruso/zashboard/releases/latest"
ZASH_DST="box_bll/clash/webroot/Zash"
ZASH_TMP="zash_dist.zip"

get_latest_tag() {
    curl -fsSL --retry 5 --retry-delay 5 \
        -H "Authorization: token $GITHUB_TOKEN" "$1" \
        | grep '"tag_name":' | head -n 1 \
        | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
}

latest_version=$(get_latest_tag "$MIHOMO_API")

if [ -z "$latest_version" ]; then
    echo "Error: Failed to fetch Mihomo version."
    exit 1
fi

echo "Latest Mihomo version: $latest_version"

download_url="${MIHOMO_BASE}/${latest_version}/${MIHOMO_NAME}-${latest_version}.gz"

echo "Downloading Mihomo core..."
if curl -fL --retry 5 --retry-delay 5 "$download_url" -o "$CORE_TMP"; then
    gunzip -c "$CORE_TMP" > "$CORE_DST"
    rm -f "$CORE_TMP"
    chmod +x "$CORE_DST"
else
    echo "Error: Mihomo download failed."
    exit 1
fi

zash_latest_version=$(get_latest_tag "$ZASH_API")
if [ -n "$zash_latest_version" ]; then
    echo "Latest Zashboard version: $zash_latest_version"
    zash_url="https://github.com/Zephyruso/zashboard/releases/download/${zash_latest_version}/dist.zip"
    echo "Downloading Zashboard..."
    if curl -fL --retry 5 --retry-delay 5 "$zash_url" -o "$ZASH_TMP"; then
        rm -rf dist Zash "$ZASH_DST"
        mkdir -p "$(dirname "$ZASH_DST")"
        unzip -q "$ZASH_TMP" -d "./zash_temp"
        if [ -d "./zash_temp/dist" ]; then
            mv "./zash_temp/dist" "$ZASH_DST"
            echo "Zashboard deployed to $ZASH_DST"
        else
            echo "Error: Unexpected ZIP structure in Zashboard."
        fi
        rm -rf zash_temp "$ZASH_TMP"
    else
        echo "Error: Zashboard download failed."
    fi
else
    echo "Error: Failed to fetch Zashboard version."
fi

APK_DIR="app/version/com.surfing.tile"
TILE_DST="SurfingTile/system/app/com.surfing.tile"
TILE_PROP="SurfingTile/module.prop"

mkdir -p "$TILE_DST"
latest_apk=$(find "$APK_DIR" -maxdepth 1 -name "SurfingTile_*_release.apk" 2>/dev/null | sort -V | tail -n 1)
if [ -f "$latest_apk" ]; then
    tile_version=$(basename "$latest_apk" | sed -E 's/^SurfingTile_(.*)_release\.apk$/\1/')
    cp -f "$latest_apk" "$TILE_DST/com.surfing.tile.apk"
    sed -i "s/^version=.*/version=v$tile_version/" "$TILE_PROP"
fi

version=$(grep '^version=' module.prop | awk -F '=' '{print $2}' | sed 's/ (.*//')
short_hash=${SHORT_HASH:-$(git rev-parse --short=7 HEAD)}

if [ "$isAlpha" = "true" ]; then
    new_version="${version} (alpha-${short_hash})"
    filename="Surfing_alpha_${short_hash}.zip"
else
    new_version="${version} (release-${short_hash})"
    filename="Surfing_${version}_release.zip"
fi

sed -i "s/^version=.*/version=${new_version}/" module.prop

(cd SurfingTile && zip -r -o -X ../SurfingTile.zip ./*)

zip -r -o -X "$filename" ./ \
    -x 'SurfingTile/*' \
    -x 'app/*' \
    -x '.git/*' \
    -x '.github/*' \
    -x 'folder/*' \
    -x 'build.sh' \
    -x 'stats.json' \
    -x 'Surfing.json' \

echo "Build Completed: $filename"