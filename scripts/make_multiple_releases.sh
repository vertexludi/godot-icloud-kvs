#!/usr/bin/env bash
set -e

PLUGIN_VERSION="$1"

if [ -z "$PLUGIN_VERSION" ]; then
	echo "Plugin version is required"
	exit 1
fi

GODOT_VERSIONS="4.3 4.4 4.4.1 4.5 4.5.1"
PLUGIN_NAME=GodotICloudKVS

cd godot
git fetch
cd ..

for VERSION in $GODOT_VERSIONS; do
	echo Making $VERSION...
	cd godot
	git switch -d $VERSION-stable
	cd ..
	./scripts/generate_headers.sh
	./scripts/make_release.sh

	mv bin/$PLUGIN_NAME.zip bin/$PLUGIN_NAME-$PLUGIN_VERSION-Godot-$VERSION.zip
done

