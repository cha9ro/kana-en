#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CONFIGURATION=${CONFIGURATION:-release}
APP_NAME=KanaEn
APP_DIR="$PROJECT_DIR/dist/$APP_NAME.app"
ICONSET_DIR="$PROJECT_DIR/Resources/$APP_NAME.iconset"
ICON_FILE="$PROJECT_DIR/Resources/$APP_NAME.icns"
SIGN_IDENTITY=${CODESIGN_IDENTITY:--}
APP_VERSION=${APP_VERSION:-}
BUILD_NUMBER=${BUILD_NUMBER:-}
ARCHITECTURES=${ARCHITECTURES:-}

cd "$PROJECT_DIR"
swift "$PROJECT_DIR/scripts/generate-icon.swift" "$ICONSET_DIR"
iconutil --convert icns --output "$ICON_FILE" "$ICONSET_DIR"

set -- -c "$CONFIGURATION"
for ARCH in $ARCHITECTURES; do
    case "$ARCH" in
        arm64|x86_64) ;;
        *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
    esac
    set -- "$@" --arch "$ARCH"
done

env \
    CLANG_MODULE_CACHE_PATH="$PROJECT_DIR/.build/clang-module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$PROJECT_DIR/.build/swiftpm-module-cache" \
    swift build "$@"

BUILD_DIR=$(env \
    CLANG_MODULE_CACHE_PATH="$PROJECT_DIR/.build/clang-module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$PROJECT_DIR/.build/swiftpm-module-cache" \
    swift build "$@" --show-bin-path)

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$PROJECT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ICON_FILE" "$APP_DIR/Contents/Resources/$APP_NAME.icns"

if [ -n "$APP_VERSION" ]; then
    /usr/libexec/PlistBuddy \
        -c "Set :CFBundleShortVersionString $APP_VERSION" \
        "$APP_DIR/Contents/Info.plist"
fi

if [ -n "$BUILD_NUMBER" ]; then
    /usr/libexec/PlistBuddy \
        -c "Set :CFBundleVersion $BUILD_NUMBER" \
        "$APP_DIR/Contents/Info.plist"
fi

codesign --force --deep --sign "$SIGN_IDENTITY" "$APP_DIR"

if [ "$SIGN_IDENTITY" = "-" ]; then
    echo "Warning: ad-hoc signing is intended for local development."
    echo "Input Monitoring permission may need to be granted again after each rebuild."
fi

echo "Built $APP_DIR"
