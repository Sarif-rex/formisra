const { loadBackendEnv } = require('../backend/loadEnv');

loadBackendEnv();

module.exports = async function handler(_req, res) {
  res.setHeader('Access-Control-Allow-Origin', process.env.CORS_ORIGIN || '*');
  return res.status(200).json({
    ok: true,
    service: 'formisra-backend',
  });
};
