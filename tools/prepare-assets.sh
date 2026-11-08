#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Normalize the generated artwork to Apple's required universal icon dimensions.
sips -s format png -z 1024 1024 Design/app-icon-source.png \
  --out Afaq/Assets.xcassets/AppIcon.appiconset/AppIcon.png >/dev/null
