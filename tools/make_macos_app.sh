#!/usr/bin/env bash
# Package the macOS build into PerfectDark.app.
#
# The ROM is NOT bundled: the port locates its data via SDL_GetPrefPath("", "perfectdark")
# (port/src/system.c), i.e. ~/Library/Application Support/perfectdark/data/pd.ntsc-final.z64,
# which is the layout the upstream README documents for macOS. That also keeps the signed
# bundle free of game data.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${1:-$ROOT/build}"
OUTDIR="${2:-$ROOT}"
APP="$OUTDIR/PerfectDark.app"
ARCH="$(uname -m)"

[ -x "$BUILD/pd.$ARCH" ] || { echo "error: $BUILD/pd.$ARCH not built" >&2; exit 1; }

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Frameworks"
cp "$BUILD/pd.$ARCH" "$APP/Contents/MacOS/PerfectDark"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>Perfect Dark</string>
    <key>CFBundleDisplayName</key><string>Perfect Dark</string>
    <key>CFBundleExecutable</key><string>PerfectDark</string>
    <key>CFBundleIdentifier</key><string>com.fgsfdsfgs.PerfectDark</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1.0</string>
    <key>LSMinimumSystemVersion</key><string>11.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key><true/>
    <key>LSApplicationCategoryType</key><string>public.app-category.games</string>
</dict>
</plist>
PLIST

# Vendor SDL2.framework so the app does not depend on /Library/Frameworks.
ditto /Library/Frameworks/SDL2.framework "$APP/Contents/Frameworks/SDL2.framework"
BIN="$APP/Contents/MacOS/PerfectDark"
install_name_tool -add_rpath @executable_path/../Frameworks "$BIN" 2>/dev/null || true

codesign --force --sign - "$APP/Contents/Frameworks/SDL2.framework" 2>/dev/null || true
codesign --force --sign - "$BIN"
codesign --force --sign - "$APP"
echo "built $APP"
