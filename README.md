# Formisra

Web romantis mobile-first untuk Misra dengan AI Syra.

## Stack

- Frontend: Flutter Web
- Backend: Node.js + Express
- AI provider: Gemini API
- Deployment target:
  - Frontend -> Vercel
  - Backend -> Render

## Local Run

### Backend

Buat file `backend/.env.openai` atau `backend/.env`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-2.5-flash-lite
PORT=3000
CORS_ORIGIN=http://localhost:3000
```

Lalu jalankan:

```bash
cd backend
npm install
node server.js
```

### Frontend

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

## Deploy Vercel + Render

### 1. Deploy backend ke Render

Repo ini sudah punya blueprint [render.yaml](./render.yaml).

Langkah:

1. Push project ke GitHub.
2. Di Render pilih `New +` -> `Blueprint`.
3. Pilih repo ini.
4. Render akan membaca `render.yaml`.
5. Isi environment variable berikut di service `formisra-backend`:
   - `GEMINI_API_KEY`
   - `CORS_ORIGIN`

Set nilai production:

```env
GEMINI_API_KEY=your_real_key
GEMINI_MODEL=gemini-2.5-flash-lite
CORS_ORIGIN=https://formisra.com
```

Setelah deploy, catat URL backend Render, misalnya:

```txt
https://formisra-backend.onrender.com
```

### 2. Deploy frontend ke Vercel

Repo ini sudah punya config [vercel.json](./vercel.json) dan build script [scripts/vercel-build.sh](./scripts/vercel-build.sh).

Langkah:

1. Di Vercel klik `Add New...` -> `Project`.
2. Import repo yang sama.
3. Framework preset pilih `Other`.
4. Tambahkan environment variable:

```env
API_BASE_URL=https://formisra-backend.onrender.com
```

5. Deploy.

Vercel akan:

- menjalankan `bash scripts/vercel-build.sh`
- install Flutter SDK
- build Flutter Web
- serve hasil `build/web`

## Domain Production

Rekomendasi:

- frontend: `https://formisra.com`
- backend: `https://api.formisra.com`

Kalau nanti pakai custom domain:

1. Hubungkan domain utama ke Vercel.
2. Hubungkan subdomain API ke Render.
3. Ubah env:

```env
API_BASE_URL=https://api.formisra.com
CORS_ORIGIN=https://formisra.com
```

## Important Notes

- Jangan commit file env berisi key asli.
- Frontend tidak boleh menyimpan API key provider.
- Render free plan bisa cold start.
- Kalau Gemini model berubah, cukup ganti `GEMINI_MODEL` di Render.

## Deploy Gratis Tanpa Kartu

Pilihan paling realistis tanpa kartu untuk backend kecil ini adalah:

- Frontend: Firebase Hosting
- Backend: Vercel Functions

Catatan penting:

- Vercel di repo ini sekarang dikonfigurasi sebagai **backend-only**
- Frontend Flutter Web jangan dideploy ke Vercel untuk jalur ini
- Frontend tetap build lokal lalu deploy ke Firebase Hosting

Endpoint Vercel yang sudah disiapkan:

- [api/health.js](./api/health.js)
- [api/chat.js](./api/chat.js)

### Langkah singkat

1. Push repo ke GitHub.
2. Import repo ini ke Vercel.
3. Saat import:
   - preset pilih `Other`
   - root directory biarkan kosong
3. Di Vercel, tambahkan environment variable:

```env
GEMINI_API_KEY=your_real_key
GEMINI_MODEL=gemini-2.5-flash-lite
CORS_ORIGIN=https://misra-romantic-web.web.app
```

4. Deploy project di Vercel.
5. Ambil domain Vercel project, misalnya:

```txt
https://formisra.vercel.app
```

6. Pastikan health check hidup:

```txt
https://formisra.vercel.app/api/health
```

7. Build ulang frontend Firebase dengan URL backend Vercel itu:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://formisra.vercel.app
firebase deploy --only hosting
```

## Checklist Deploy Hemat

- Pakai `gemini-2.5-flash-lite` sebagai model default.
- Pastikan frontend hanya memanggil backend, tidak pernah provider AI langsung.
- Set `CORS_ORIGIN` spesifik ke domain frontend production.
- Batasi history chat yang dikirim ke backend agar token tetap kecil.
- Batasi panjang pesan user agar request tidak membengkak.
- Gunakan Flutter build release dengan `--dart-define=API_BASE_URL=...`.
- Deploy backend di platform yang bisa scale down saat idle.
- Simpan API key hanya di environment deployment, bukan di repo.
- Uji `GET /health` dan `POST /api/chat` setelah deploy.
- Pantau usage Gemini beberapa hari pertama untuk lihat pola biaya/quota.

## Deploy Firebase + Cloud Run

Setup ini paling cocok kalau kamu ingin frontend tetap static dan backend Express tetap dipakai tanpa dipindah ke Firebase Functions.

### File yang dipakai

- Firebase Hosting config: [firebase.json](./firebase.json)
- Template project Firebase: [.firebaserc.example](./.firebaserc.example)
- Cloud Run container backend: [backend/Dockerfile](./backend/Dockerfile)
- Build helper frontend: [scripts/firebase-build.sh](./scripts/firebase-build.sh)
- PowerShell deploy helper: [scripts/deploy-cloudrun.ps1](./scripts/deploy-cloudrun.ps1)
- PowerShell web build helper: [scripts/build-firebase-web.ps1](./scripts/build-firebase-web.ps1)

### 1. Deploy backend ke Cloud Run

Aktifkan dulu API berikut di project Google Cloud:

- Cloud Run API
- Artifact Registry API

Lalu deploy backend dari folder `backend`:

```bash
gcloud run deploy formisra-backend ^
  --source backend ^
  --region asia-southeast2 ^
  --allow-unauthenticated ^
  --set-env-vars GEMINI_API_KEY=your_real_key,GEMINI_MODEL=gemini-2.5-flash-lite,CORS_ORIGIN=https://your-project.web.app
```

Atau pakai helper PowerShell:

```powershell
.\scripts\deploy-cloudrun.ps1 `
  -ProjectId your-project-id `
  -GeminiApiKey your_real_key `
  -CorsOrigin https://your-project.web.app
```

Setelah berhasil, kamu akan dapat URL Cloud Run, misalnya:

```txt
https://formisra-backend-xxxxx-as.a.run.app
```

### 2. Deploy frontend ke Firebase Hosting

Install Firebase CLI dan login:

```bash
npm install -g firebase-tools
firebase login
```

Salin template project:

```bash
copy .firebaserc.example .firebaserc
```

Isi `.firebaserc` dengan Firebase project id kamu.

Build frontend:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://formisra-backend-xxxxx-as.a.run.app
```

Atau pakai helper PowerShell:

```powershell
.\scripts\build-firebase-web.ps1 `
  -ApiBaseUrl https://formisra-backend-xxxxx-as.a.run.app
```

Lalu deploy:

```bash
firebase deploy --only hosting
```

### 3. Production domain

Kalau frontend sudah di Firebase Hosting dan backend di Cloud Run:

- frontend: `https://your-project.web.app`
- backend: URL Cloud Run

Kalau nanti pakai custom domain:

- arahkan domain utama ke Firebase Hosting
- set `CORS_ORIGIN=https://formisra.com` di Cloud Run
- rebuild frontend dengan:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-cloud-run-url
```

### 4. Opsi satu domain

Kalau kamu ingin frontend dan API terlihat dari domain yang sama, ada dua jalur:

1. Pakai Firebase Hosting untuk frontend dan panggil langsung URL Cloud Run dari frontend.
2. Tambahkan reverse proxy atau Hosting rewrite ke backend terpisah setelah domain production stabil.

Untuk versi awal, jalur paling sederhana adalah:

- Firebase Hosting untuk frontend
- Cloud Run URL langsung untuk `API_BASE_URL`
