#!/usr/bin/env bash
# Source this file from any directory to use the workspace Android toolchain.
VIRPANAI_TOOLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/.local-tools"
export JAVA_HOME="$VIRPANAI_TOOLS_ROOT/jdk-17"
export ANDROID_HOME="$VIRPANAI_TOOLS_ROOT/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$VIRPANAI_TOOLS_ROOT/flutter/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
