const fs = require('fs');
const path = require('path');

const dotenv = require('dotenv');

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
    dotenv.config({ path: envPath });
  }

  loaded = true;
}

module.exports = {
  loadBackendEnv,
};
