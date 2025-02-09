#!/bin/bash

set -eu

function swift_build() {
    SWIFTUI_ATOM_PROPERTIES_DEVELOPMENT=1 swift build -c release --only-use-versions-from-resolved-file $@
}

PACKAGE=$1
ARGS=${@:2}
BIN_DIR="bin"
BIN="$BIN_DIR/$PACKAGE"
CHECKSUM_FILE="$BIN.checksum"

pushd "$(cd $(dirname $0)/.. && pwd)" &>/dev/null

swift_version="$(swift --version 2>/dev/null | head -n 1)"
swift_version_hash=$(echo $swift_version | md5 -q)
package_hash=$(md5 -q Package.swift)
checksum=$(echo $swift_version_hash $package_hash | md5 -q)

echo "CHECKSUM: $checksum"

if [[ ! -f $BIN || $checksum != $(cat $CHECKSUM_FILE 2>/dev/null) ]]; then
    echo "Building..."
    swift_build --product $PACKAGE
    mkdir -p $BIN_DIR
    mv -f $(swift_build --show-bin-path)/$PACKAGE $BIN

    if [[ -e ${SWIFT_PACKAGE_RESOURCES:-} ]]; then
        echo "Copying $SWIFT_PACKAGE_RESOURCES..."
        cp -R $SWIFT_PACKAGE_RESOURCES $BIN_DIR
    fi

    echo "$checksum" >"$CHECKSUM_FILE"
fi

$BIN $ARGS
