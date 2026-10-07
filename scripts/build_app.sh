#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/Pomodoro Bar.app"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$ROOT_DIR/.build/release/PomodoroBar" "$APP_DIR/Contents/MacOS/PomodoroBar"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>PomodoroBar</string>
  <key>CFBundleIdentifier</key>
  <string>com.wookiist.pomodoro-bar</string>
  <key>CFBundleName</key>
  <string>Pomodoro Bar</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>26.0</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP_DIR" >/dev/null
echo "$APP_DIR"
