#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"
ORG_GRADLE_PROJECT_signingProfile=buildmerchant flutter build appbundle --release
