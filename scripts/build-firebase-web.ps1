param(
  [Parameter(Mandatory = $true)]
  [string]$ApiBaseUrl
)

$ErrorActionPreference = "Stop"

flutter pub get
flutter build web --release --dart-define="API_BASE_URL=$ApiBaseUrl"
