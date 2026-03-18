const fs = require('fs');
const path = require('path');

let loaded = false;

function loadBackendEnv() {
  if (loaded) {
    return;
  }

  const rootDir = path.resolve(__dirname);
  const preferredEnvPath = path.join(rootDir, '.env.openai');
  const fallbackEnvPath = path.join(rootDir, '.env');
  const envPath = fs.existsSync(preferredEnvPath)
    ? preferredEnvPath
    : fallbackEnvPath;

  if (fs.existsSync(envPath)) {
    try {
      const dotenv = require('dotenv');
      dotenv.config({ path: envPath });
    } catch (_) {
      // On serverless platforms like Vercel, environment variables are injected
      // by the platform and dotenv does not need to be present.
    }
  }

  loaded = true;
}

module.exports = {
  loadBackendEnv,
};
