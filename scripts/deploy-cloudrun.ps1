param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,

  [Parameter(Mandatory = $true)]
  [string]$GeminiApiKey,

  [Parameter(Mandatory = $true)]
  [string]$CorsOrigin,

  [string]$ServiceName = "formisra-backend",
  [string]$Region = "asia-southeast2",
  [string]$GeminiModel = "gemini-2.5-flash-lite"
)

$ErrorActionPreference = "Stop"

gcloud config set project $ProjectId

gcloud run deploy $ServiceName `
  --source backend `
  --region $Region `
  --project $ProjectId `
  --allow-unauthenticated `
  --set-env-vars "GEMINI_API_KEY=$GeminiApiKey,GEMINI_MODEL=$GeminiModel,CORS_ORIGIN=$CorsOrigin"
