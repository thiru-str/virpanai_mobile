#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dev-env.sh"
cd "$(dirname "$0")/.."

devices=()
while read -r serial state rest; do
  if [[ "$state" == "device" ]]; then devices+=("$serial"); fi
done < <(adb devices)

device_id="${1:-}"
if [[ -z "$device_id" ]]; then
  if [[ ${#devices[@]} -ne 1 ]]; then
    echo "Connect one Android phone, enable USB debugging, and accept its authorization prompt."
    echo "For multiple phones: bash tool/run-android.sh DEVICE_ID"
    adb devices -l
    exit 1
  fi
  device_id="${devices[0]}"
fi

flutter run -d "$device_id"
