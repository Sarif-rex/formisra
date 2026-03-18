const express = require('express');

const { AiServiceError, generateSyraReply } = require('../services/aiService');

const router = express.Router();

router.post('/', async (req, res) => {
  const { message, history } = req.body || {};

  if (typeof message !== 'string' || !message.trim()) {
    return res.status(400).json({
      error: 'Pesan wajib diisi.',
    });
  }

  try {
    const reply = await generateSyraReply({
      message,
      history,
    });

    return res.json({
      reply,
    });
  } catch (error) {
    console.error('Chat route error:', error);
    const statusCode = error instanceof AiServiceError ? error.statusCode : 500;
    return res.status(statusCode).json({
      error:
        error instanceof AiServiceError
          ? error.message
          : 'Syra belum bisa membalas sekarang.',
      code: error instanceof AiServiceError ? error.code : 'unknown_error',
    });
  }
});

module.exports = router;
