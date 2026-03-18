const { loadBackendEnv } = require('../backend/loadEnv');
const {
  AiServiceError,
  generateSyraReply,
} = require('../backend/services/aiService');

loadBackendEnv();

module.exports = async function handler(req, res) {
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({
      error: 'Method tidak didukung.',
      code: 'method_not_allowed',
    });
  }

  const { message, history } = req.body || {};

  if (typeof message !== 'string' || !message.trim()) {
    return res.status(400).json({
      error: 'Pesan wajib diisi.',
      code: 'empty_message',
    });
  }

  try {
    const reply = await generateSyraReply({
      message,
      history,
    });

    return res.status(200).json({ reply });
  } catch (error) {
    console.error('Vercel chat error:', error);
    const statusCode = error instanceof AiServiceError ? error.statusCode : 500;
    return res.status(statusCode).json({
      error:
        error instanceof AiServiceError
          ? error.message
          : 'Syra belum bisa membalas sekarang.',
      code: error instanceof AiServiceError ? error.code : 'unknown_error',
    });
  }
};

function setCorsHeaders(res) {
  const corsOrigin = process.env.CORS_ORIGIN || '*';
  res.setHeader('Access-Control-Allow-Origin', corsOrigin === '*' ? '*' : corsOrigin);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}
