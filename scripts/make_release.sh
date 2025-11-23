#!/bin/bash
set -e

# CHANGE THIS to the project name.
PLUGIN_NAME=GodotICloudKVS

# Check if godot headers were generated.
if [[ $(find godot -name '*.gen.h' | wc -l | awk '{$1=$1};1') == 0 ]]; then
	./scripts/generate_headers.sh
fi

# Build archives
xcrun xcodebuild archive -project ${PLUGIN_NAME}.xcodeproj -scheme ${PLUGIN_NAME} -destination "generic/platform=iOS" -archivePath "bin/archives/${PLUGIN_NAME}.debug" -configuration Debug
xcrun xcodebuild archive -project ${PLUGIN_NAME}.xcodeproj -scheme ${PLUGIN_NAME} -destination "generic/platform=iOS" -archivePath "bin/archives/${PLUGIN_NAME}.release" -configuration Release

# Build xcframework
xcrun xcodebuild -create-xcframework \
		-archive bin/archives/${PLUGIN_NAME}.debug.xcarchive -library lib${PLUGIN_NAME}.a \
		-output bin/xcframeworks/${PLUGIN_NAME}.debug.xcframework
xcrun xcodebuild -create-xcframework \
		-archive bin/archives/${PLUGIN_NAME}.release.xcarchive -library lib${PLUGIN_NAME}.a \
		-output bin/xcframeworks/${PLUGIN_NAME}.release.xcframework

# Move all to release folder
PLUGIN_PATH=bin/ios/plugins/${PLUGIN_NAME}
ADDON_PATH=bin/addons/${PLUGIN_NAME}
rm -rf bin/ios
rm -rf bin/addons
mkdir -p ${PLUGIN_PATH}
mkdir -p bin/addons

cp ${PLUGIN_NAME}/${PLUGIN_NAME}.gdip ${PLUGIN_PATH}
mv bin/xcframeworks/${PLUGIN_NAME}.debug.xcframework ${PLUGIN_PATH}
mv bin/xcframeworks/${PLUGIN_NAME}.release.xcframework ${PLUGIN_PATH}/

rm -rf bin/xcframeworks
rm -rf bin/archives

cp -r wrapper ${ADDON_PATH}

cd bin
rm -rf ${PLUGIN_NAME}.zip
zip -r ${PLUGIN_NAME} ios addons
cd ..
