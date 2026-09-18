#!/bin/bash
set -e

FLUTTER_VERSION="3.44.8"

echo "Installing Flutter ${FLUTTER_VERSION}..."

git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git "$HOME/flutter"

export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"

flutter --version

flutter config --enable-web

flutter pub get

flutter build web --release
