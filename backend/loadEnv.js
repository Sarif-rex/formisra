const fs = require('fs');
const path = require('path');

let loaded = false;

function loadBackendEnv() {
  if (loaded) {
    return;
  }

  const rootDir = path.resolve(__dirname);
  const envCandidates = ['.env.openrouter', '.env.openai', '.env']
    .map((fileName) => path.join(rootDir, fileName));
  const envPath = envCandidates.find((candidate) => fs.existsSync(candidate));

  if (envPath && fs.existsSync(envPath)) {
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
