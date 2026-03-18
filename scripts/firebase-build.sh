#!/usr/bin/env bash
set -euo pipefail

flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL}"
