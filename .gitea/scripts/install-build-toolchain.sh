#!/usr/bin/env bash
# Installs what a clean checkout of this app needs and the runner image is not
# assumed to carry: a Temurin JDK 21 and the Android SDK (platform 34,
# build-tools 34.0.0). Both go inside the workspace, so two jobs running at the
# same time share nothing — the shared tool cache actions/setup-java writes to
# raced and lost one job on this workflow's first run. Licenses are accepted so
# AGP can fetch a newer build-tools itself when its plugin version prefers one.
# No secret is needed. Re-running it is a no-op.
set -euo pipefail

root="${GITHUB_WORKSPACE:-$PWD}"
jdk="${root}/toolchain/jdk21"
sdk="${ANDROID_HOME:-${root}/android-sdk}"
tmp="${TMPDIR:-/tmp}"
export ANDROID_HOME="${sdk}" ANDROID_SDK_ROOT="${sdk}"

jdk_url="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12%2B8/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12_8.tar.gz"
if [ ! -x "${jdk}/bin/javac" ]; then
  mkdir -p "${jdk}"
  curl -fsSL -o "${tmp}/jdk21.tar.gz" "${jdk_url}"
  tar xzf "${tmp}/jdk21.tar.gz" -C "${jdk}" --strip-components=1
fi
"${jdk}/bin/javac" -version

manager="${sdk}/cmdline-tools/latest/bin/sdkmanager"
if [ ! -x "${manager}" ]; then
  mkdir -p "${sdk}/cmdline-tools"
  curl -fsSL -o "${tmp}/cmdline-tools.zip" \
    https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
  unzip -q -o "${tmp}/cmdline-tools.zip" -d "${tmp}/cmdline-tools-extract"
  rm -rf "${sdk}/cmdline-tools/latest"
  mv "${tmp}/cmdline-tools-extract/cmdline-tools" "${sdk}/cmdline-tools/latest"
fi

yes | "${manager}" --licenses >/dev/null || true
"${manager}" --sdk_root="${sdk}" "platforms;android-34" "build-tools;34.0.0" >/dev/null

echo "Toolchain ready: JDK 21 in ${jdk}, Android SDK in ${sdk}"
