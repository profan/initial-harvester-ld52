#!/usr/bin/env sh

# build dir loonix
# GODOT=godot
# BUILD_DIR=/home/profan/godot-builds/memento-mori

# build dir windows
GODOT=/c/Personal/Tools/Godot/Godot_v3.5.1-stable_win64.exe
BUILD_DIR=/c/Personal/Builds/thresher
VERSION="1.0.0"

# debug builds used to be the safer option, but we might as well hope release is fine? :P
USE_DEBUG_BUILDS=false

# set if we want to actually push to butler
PUSH_TO_BUTLER=true

# make the DIRS
mkdir -p $BUILD_DIR/th_win64/
mkdir -p $BUILD_DIR/th_lin64/
mkdir -p $BUILD_DIR/th_osx64/
mkdir -p $BUILD_DIR/th_android/

# build THE FUCKER
if $USE_DEBUG_BUILDS
then
	$GODOT --no-window --export-debug "Windows Desktop" $BUILD_DIR/th_win64/mm.exe
	$GODOT --no-window --export-debug "Linux/X11" $BUILD_DIR/th_lin64/mm
	$GODOT --no-window --export-debug "Mac OSX" $BUILD_DIR/th_osx64/th.zip
	$GODOT --no-window --export-debug Android $BUILD_DIR/th_android/th.apk
else
	$GODOT --no-window --export "Windows Desktop" $BUILD_DIR/th_win64/th.exe
	$GODOT --no-window --export "Linux/X11" $BUILD_DIR/th_lin64/th
	$GODOT --no-window --export "Mac OSX" $BUILD_DIR/th_osx64/th.zip
	$GODOT --no-window --export Android $BUILD_DIR/th_android/th.apk
fi

# push THE FUCKER, if it's time

if $PUSH_TO_BUTLER
then
	butler push $BUILD_DIR/mm_win64 profan/thresher:win64-release --userversion $VERSION
	butler push $BUILD_DIR/mm_lin64 profan/thresher:lin64-release --userversion $VERSION
	butler push $BUILD_DIR/mm_osx64 profan/thresher:osx-release --userversion $VERSION
	butler push $BUILD_DIR/mm_android profan/thresher:android-release --userversion $VERSION
fi
