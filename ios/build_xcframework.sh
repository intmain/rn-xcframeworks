#!/bin/bash

set -euo pipefail

export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"

exclude_frameworks=("PINCache" "PINOperation" "PINRemoteImage" "Pods_ios_rn_prebuilt" "ios_rn_prebuilt")

export SRCROOT=$(pwd)
export PROJECT=RNPrebuild

function archive() {
    xcodebuild archive \
    -workspace $PROJECT.xcworkspace \
    -scheme $PROJECT \
    -archivePath $SRCROOT/$PROJECT-iphonesimulator.xcarchive \
    -sdk iphonesimulator \
    SKIP_INSTALL=NO
 xcodebuild archive \
    -workspace $PROJECT.xcworkspace \
    -scheme $PROJECT \
    -archivePath $SRCROOT/$PROJECT-iphoneos.xcarchive \
    -sdk iphoneos \
    SKIP_INSTALL=NO
}

function create_xcframework() {
    rm -rf $SRCROOT/Frameworks
    mkdir $SRCROOT/Frameworks

    # Find frameworks
    for framework in $(find $SRCROOT/$PROJECT-iphonesimulator.xcarchive/Products/Library/Frameworks -type d -name "*.framework");
    do
        basename=$(basename $framework)
        framework_name=$(basename $framework .framework)

        if [[ " ${exclude_frameworks[*]} " =~ " ${framework_name} "  ]]; then
            continue
        fi

        xcodebuild -create-xcframework \
            -framework $SRCROOT/$PROJECT-iphonesimulator.xcarchive/Products/Library/Frameworks/$basename \
            -framework $SRCROOT/$PROJECT-iphoneos.xcarchive/Products/Library/Frameworks/$basename \
            -output $SRCROOT/Frameworks/$framework_name.xcframework
    done
    # Find bundle resources
    for resources in $(find $BUILT_PRODUCTS_DIR/../.. -type d -name "*.bundle");
    do
        cp -R $resources $SRCROOT/Frameworks/
    done

    tar -cvzf $PROJECT.tar.gz Frameworks
}

function clean() {
    # Clean Up
    rm -rf $SRCROOT/$PROJECT-iphoneos.xcarchive
    rm -rf $SRCROOT/$PROJECT-iphonesimulator.xcarchive
    rm -rf $SRCROOT/Frameworks
}

# function distribute() {
#     echo 9
#     gh release create "$1" --generate-notes -R "traveloka/ios-rn-prebuilt"
#     gh release upload "$1" $PROJECT.tar.gz -R "traveloka/ios-rn-prebuilt" && rm -rf $PROJECT.tar.gz

#     pod repo push traveloka ios-rn-prebuilt.podspec --verbose --allow-warnings --skip-tests
#     echo 10
# }

cd $SRCROOT
#version=$(cat ios-rn-prebuilt.podspec | grep version | sed -n 's/version.=."\(.*\)".*/\1/p' | xargs)
version=1.0.0

archive
create_xcframework
# clean
# distribute $version
