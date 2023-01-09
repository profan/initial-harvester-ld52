#!/usr/bin/env sh

# build dir loonix
# GODOT=godot
# BUILD_DIR=/home/profan/godot-builds/initial-harvester

# build dir windows
GODOT=/c/Personal/Tools/Godot/Godot_v3.5.1-stable_win64.exe
BUILD_DIR=/c/Personal/Builds/initial-harvester
VERSION="1.0.0"

# debug builds used to be the safer option, but we might as well hope release is fine? :P
USE_DEBUG_BUILDS=false

# set if we want to actually push to butler
PUSH_TO_BUTLER=false

# make the DIRS
mkdir -p $BUILD_DIR/ih_win64/
mkdir -p $BUILD_DIR/ih_lin64/
mkdir -p $BUILD_DIR/ih_osx64/
mkdir -p $BUILD_DIR/ih_web/

# build THE FUCKER
if $USE_DEBUG_BUILDS
then
	$GODOT --no-window --export-debug "Windows Desktop" $BUILD_DIR/ih_win64/ih.exe
	$GODOT --no-window --export-debug "Linux/X11" $BUILD_DIR/ih_lin64/ih
	# $GODOT --no-window --export-debug "Mac OSX" $BUILD_DIR/ih_osx64/ih.zip
	$GODOT --no-window --export-debug "HTML5" $BUILD_DIR/ih_web/index.html
else
	$GODOT --no-window --export "Windows Desktop" $BUILD_DIR/ih_win64/ih.exe
	$GODOT --no-window --export "Linux/X11" $BUILD_DIR/ih_lin64/ih
	# $GODOT --no-window --export "Mac OSX" $BUILD_DIR/ih_osx64/ih.zip
	$GODOT --no-window --export "HTML5" $BUILD_DIR/ih_web/index.html
fi

# push THE FUCKER, if it's time
if $PUSH_TO_BUTLER
then
	butler push $BUILD_DIR/ih_win64 profan/initial-harvester:win64-release --userversion $VERSION
	butler push $BUILD_DIR/ih_lin64 profan/initial-harvester:lin64-release --userversion $VERSION
	# butler push $BUILD_DIR/ih_osx64 profan/initial-harvester:osx-release --userversion $VERSION
	butler push $BUILD_DIR/ih_web profan/initial-harvester:web-release --userversion $VERSION
fi
