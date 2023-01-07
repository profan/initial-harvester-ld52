#!/usr/bin/env sh

# build dir loonix
# GODOT=godot
# BUILD_DIR=/home/profan/godot-builds/memento-mori

# build dir windows
GODOT=/c/Personal/Tools/Godot/Godot_v3.2.3-stable_win64.exe
BUILD_DIR=/c/Personal/Builds/memento-mori
VERSION="1.3.2"

# debug builds used to be the safer option, but we might as well hope release is fine? :P
USE_DEBUG_BUILDS=false

# set if we want to actually push to butler
PUSH_TO_BUTLER=true

# make the DIRS
mkdir -p $BUILD_DIR/mm_win64/
mkdir -p $BUILD_DIR/mm_lin64/
mkdir -p $BUILD_DIR/mm_osx64/
mkdir -p $BUILD_DIR/mm_android/

# build THE FUCKER
if $USE_DEBUG_BUILDS
then
	$GODOT --no-window --export-debug "Windows Desktop" $BUILD_DIR/mm_win64/mm.exe
	$GODOT --no-window --export-debug "Linux/X11" $BUILD_DIR/mm_lin64/mm
	$GODOT --no-window --export-debug "Mac OSX" $BUILD_DIR/mm_osx64/mm.zip
	$GODOT --no-window --export-debug Android $BUILD_DIR/mm_android/mm.apk
else
	$GODOT --no-window --export "Windows Desktop" $BUILD_DIR/mm_win64/mm.exe
	$GODOT --no-window --export "Linux/X11" $BUILD_DIR/mm_lin64/mm
	$GODOT --no-window --export "Mac OSX" $BUILD_DIR/mm_osx64/mm.zip
	$GODOT --no-window --export Android $BUILD_DIR/mm_android/mm.apk
fi

# push THE FUCKER, if it's time

if $PUSH_TO_BUTLER
then
	butler push $BUILD_DIR/mm_win64 profan/memento-mori:win64-release --userversion $VERSION
	butler push $BUILD_DIR/mm_lin64 profan/memento-mori:lin64-release --userversion $VERSION
	butler push $BUILD_DIR/mm_osx64 profan/memento-mori:osx-release --userversion $VERSION
	butler push $BUILD_DIR/mm_android profan/memento-mori:android-release --userversion $VERSION
fi
