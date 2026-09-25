#!/usr/bin/env bash
# Captures the raw store screenshots and renders the captioned frames.
#
#   ./scripts/store-screenshots.sh              # iphone, ipad and android
#   ./scripts/store-screenshots.sh android      # one or more of: iphone ipad android
#   SKIP_BUILD=1 ./scripts/store-screenshots.sh # reuse the last debug build
#   SKIP_RENDER=1 ./scripts/store-screenshots.sh
#
# Every screen is reached by URL, so no step taps or types:
#   iOS      xcrun simctl openurl <udid> https://podcasterium.com/<route>
#            (universal link; the live AASA covers every route used here)
#   Android  am start -d com.podcasterium://podcasterium.com/<route>
#            (the custom scheme; the https App Links allow-list has no /search,
#            and a debug build is not verified for podcasterium.com anyway)
#
# Nothing drives the host mouse or keyboard, so the Mac stays usable during a
# run: `simctl` works on a booted simulator without the Simulator.app window
# (quit Simulator.app to keep it hidden), and the emulator runs headless.
#
# The app is reinstalled before each device run, so it starts signed out with
# an empty history. The episode screens run before home, so home shows the
# pinned episode under "Continue listening".
#
# Needs: .env with the five build-time keys (see docs/04 §4), the core
# checkout from pubspec_overrides.yaml, Xcode simulators named below, and an
# Android AVD named $AVD (created once, see docs/05-store-launch.md §6).
# Also a regression test: a route that stops resolving, or a screen that
# changes, shows up in the diff of store-assets/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ── What gets captured ─────────────────────────────────────────────────────
# Episode that leads the home carousel (core `HomeFeed.heroPin`). Only this
# script sets it; every real build leaves it empty.
HERO_PIN="oxq1U0xypu8"
EPISODE="fO7iltytw0I"

# name|route|seconds to wait after opening. Captured in this order; the file
# name carries the store order.
SHOTS=(
  "02-player|/v/${EPISODE}/en?t=44&video=1|20"
  "03-article|/v/${EPISODE}/en?t=44&video=0|14"
  "04-search|/search?q=liberland|10"
  "05-person|/p/matija-stepanic|10"
  "06-channel|/c/domovina-tv|10"
  "01-home|/|12"
)

IPHONE_SIM="iPhone 17 Pro Max"      # 1320×2868
IPAD_SIM="iPad Pro 13-inch (M5)"    # 2064×2752
AVD="${AVD:-podcasterium_shots}"    # Pixel 7 profile, 1080×2400, API 35
BUNDLE_ID="com.podcasterium"

TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=(iphone ipad android)

log() { printf '\033[1m▸ %s\033[0m\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ── Build-time defines from .env ───────────────────────────────────────────
DEFINES="$(mktemp -t podcasterium-defines).json"
trap 'rm -f "$DEFINES"' EXIT
python3 - "$DEFINES" "$HERO_PIN" <<'PY'
import json, sys
keys = ["SUPABASE_URL", "SUPABASE_ANON_KEY", "MEILI_URL",
        "RC_PUBLIC_SDK_KEY_IOS", "RC_PUBLIC_SDK_KEY_ANDROID"]
env = {}
for line in open(".env"):
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        k, v = line.split("=", 1)
        env[k.strip()] = v.strip().strip('"').strip("'")
missing = [k for k in keys if not env.get(k)]
if missing:
    sys.exit(f".env lacks {', '.join(missing)}")
out = {k: env[k] for k in keys}
out["HERO_PIN"] = sys.argv[2]
json.dump(out, open(sys.argv[1], "w"))
PY

to_jpeg() { # <png> <jpg>
  sips -s format jpeg -s formatOptions 90 "$1" --out "$2" >/dev/null
  rm -f "$1"
}

# ── iOS ────────────────────────────────────────────────────────────────────
sim_udid() {
  xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
for runtime, devices in sorted(json.load(sys.stdin)["devices"].items(), reverse=True):
    for d in devices:
        if d["name"] == name:
            print(d["udid"]); sys.exit()
sys.exit("no simulator named " + name)' "$1"
}

IOS_BUILT=""
build_ios() {
  [ -n "$IOS_BUILT" ] && return
  IOS_BUILT=1
  [ -n "${SKIP_BUILD:-}" ] && [ -d build/ios/iphonesimulator/Runner.app ] && return
  log "flutter build ios --simulator --debug"
  flutter build ios --simulator --debug --dart-define-from-file="$DEFINES"
}

capture_ios() { # <folder> <simulator name>
  local folder="$1" udid
  udid="$(sim_udid "$2")"
  log "$2 ($udid) → store-assets/$folder"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl status_bar "$udid" override --time 9:41 \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 \
    --batteryState charged --batteryLevel 100
  xcrun simctl uninstall "$udid" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$udid" build/ios/iphonesimulator/Runner.app
  xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
  sleep 12
  mkdir -p "store-assets/$folder"
  local shot name route wait
  for shot in "${SHOTS[@]}"; do
    IFS='|' read -r name route wait <<<"$shot"
    xcrun simctl openurl "$udid" "https://podcasterium.com${route}"
    sleep "$wait"
    xcrun simctl io "$udid" screenshot --type=png "store-assets/$folder/$name.png" >/dev/null
    to_jpeg "store-assets/$folder/$name.png" "store-assets/$folder/$name.jpg"
    echo "  $name  $route"
  done
  xcrun simctl status_bar "$udid" clear
  xcrun simctl shutdown "$udid"
}

# ── Android ────────────────────────────────────────────────────────────────
ensure_emulator() {
  # The player's video stays black in emulator captures with any GPU mode
  # (docs/05-store-launch.md §6, known gap).
  if ! adb get-state >/dev/null 2>&1; then
    local sdk="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
    log "booting emulator $AVD (headless)"
    nohup "$sdk/emulator/emulator" -avd "$AVD" -no-window -no-audio \
      -no-boot-anim -no-snapshot -gpu host >/tmp/podcasterium-emulator.log 2>&1 &
    adb wait-for-device
  fi
  # boot_completed alone is not enough: with too little RAM system_server
  # restarts after it, and `pm install` fails with "Can't find service".
  until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] &&
    adb shell service check package 2>/dev/null | grep -q ': found'; do
    sleep 3
  done
}

build_android() {
  [ -n "${SKIP_BUILD:-}" ] && [ -f build/app/outputs/flutter-apk/app-debug.apk ] && return
  log "flutter build apk --debug"
  flutter build apk --debug --dart-define-from-file="$DEFINES"
}

capture_android() {
  ensure_emulator
  log "Android ($(adb shell getprop ro.product.model | tr -d '\r')) → store-assets/android"
  adb uninstall "$BUNDLE_ID" >/dev/null 2>&1 || true
  adb install -r build/app/outputs/flutter-apk/app-debug.apk >/dev/null
  # SystemUI demo mode: fixed clock, full battery and signal, no notifications.
  adb shell settings put global sysui_demo_allowed 1
  local b="am broadcast -a com.android.systemui.demo -e command"
  adb shell "$b enter" >/dev/null
  adb shell "$b clock -e hhmm 0941" >/dev/null
  adb shell "$b battery -e level 100 -e plugged false" >/dev/null
  adb shell "$b network -e wifi show -e level 4 -e mobile show -e datatype none -e level 4" >/dev/null
  adb shell "$b notifications -e visible false" >/dev/null
  local main
  main="$(adb shell cmd package resolve-activity --brief \
    -c android.intent.category.LAUNCHER "$BUNDLE_ID" | tail -1 | tr -d '\r')"
  adb shell am start -W -n "$main" >/dev/null
  sleep 15
  mkdir -p store-assets/android
  local shot name route wait
  for shot in "${SHOTS[@]}"; do
    IFS='|' read -r name route wait <<<"$shot"
    adb shell "am start -W -a android.intent.action.VIEW \
      -d 'com.podcasterium://podcasterium.com${route}' -p $BUNDLE_ID" >/dev/null
    sleep "$wait"
    adb exec-out screencap -p >"store-assets/android/$name.png"
    to_jpeg "store-assets/android/$name.png" "store-assets/android/$name.jpg"
    echo "  $name  $route"
  done
  adb shell "$b exit" >/dev/null
}

# ── Run ────────────────────────────────────────────────────────────────────
for t in "${TARGETS[@]}"; do
  case "$t" in
    iphone) build_ios; capture_ios ios-iphone "$IPHONE_SIM" ;;
    ipad) build_ios; capture_ios ios-ipad "$IPAD_SIM" ;;
    android) build_android; capture_android ;;
    *) die "unknown target $t (iphone, ipad, android)" ;;
  esac
done

if [ -z "${SKIP_RENDER:-}" ]; then
  log "rendering captioned frames"
  cd store-assets/marketing
  [ -d node_modules ] || npm install
  # Reuse a cached Chromium instead of letting Playwright download one.
  if [ -z "${CHROMIUM_PATH:-}" ]; then
    CHROMIUM_PATH="$(command ls -d "$HOME"/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-arm64/chrome-headless-shell 2>/dev/null | tail -1)"
    [ -n "$CHROMIUM_PATH" ] && export CHROMIUM_PATH
  fi
  npm run render
fi
