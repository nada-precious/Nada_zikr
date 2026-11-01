#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# Navigate to workspace root
cd "$CI_WORKSPACE"

# Install Flutter using git
echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# Precache iOS artifacts
echo "=== Pre-caching Flutter iOS artifacts ==="
flutter precache --ios

# Install Flutter dependencies
echo "=== Running flutter pub get ==="
flutter pub get

# Install CocoaPods
echo "=== Installing CocoaPods ==="
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Install Pods
echo "=== Running pod install ==="
cd ios
pod install

exit 0
