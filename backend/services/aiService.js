const { syraSystemPrompt } = require('../prompts/syraPrompt');

const MAX_HISTORY_MESSAGES = 8;
const MAX_MESSAGE_CHARS = 400;

function normalizeMessageText(text) {
  return String(text).trim().replace(/\s+/g, ' ').slice(0, MAX_MESSAGE_CHARS);
}

class AiServiceError extends Error {
  constructor({ message, statusCode = 500, code = 'ai_error' }) {
    super(message);
    this.name = 'AiServiceError';
    this.statusCode = statusCode;
    this.code = code;
  }
}

function mapHistoryToContents(history) {
  if (!Array.isArray(history)) {
    return [];
  }

  return history
    .filter((item) => item && typeof item.text === 'string' && item.text.trim())
    .slice(-MAX_HISTORY_MESSAGES)
    .map((item) => ({
      role: item.role === 'assistant' ? 'model' : 'user',
      parts: [
        {
          text: normalizeMessageText(item.text),
        },
      ],
    }));
}

async function generateSyraReply({ message, history = [] }) {
  const apiKey = process.env.GEMINI_API_KEY;
  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite';

  if (!apiKey) {
    throw new AiServiceError({
      message: 'Backend belum siap untuk membalas chat sekarang.',
      statusCode: 500,
      code: 'missing_api_key',
    });
  }

  const normalizedMessage = normalizeMessageText(message);

  if (!normalizedMessage) {
    throw new AiServiceError({
      message: 'Pesan wajib diisi.',
      statusCode: 400,
      code: 'empty_message',
    });
  }

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: JSON.stringify({
        system_instruction: {
          parts: [
            {
              text: syraSystemPrompt,
            },
          ],
        },
        contents: [
          ...mapHistoryToContents(history),
          {
            role: 'user',
            parts: [
              {
                text: normalizedMessage,
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 220,
          temperature: 0.8,
          topP: 0.9,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();
    throw mapGeminiError(response.status, errorBody);
  }

  const data = await response.json();
  const reply = data.candidates
    ?.flatMap((candidate) => candidate.content?.parts ?? [])
    ?.map((part) => part.text)
    ?.filter(Boolean)
    ?.join('')
    ?.trim();

  if (!reply) {
    throw new AiServiceError({
      message: 'Syra belum bisa membalas sekarang.',
      statusCode: 502,
      code: 'empty_ai_reply',
    });
  }

  return reply;
}

function mapGeminiError(status, errorBody) {
  const normalizedBody = String(errorBody);

  if (status === 400) {
    return new AiServiceError({
      message: 'Permintaan chat belum valid.',
      statusCode: 400,
      code: 'invalid_request',
    });
  }

  if (status === 401 || status === 403) {
    return new AiServiceError({
      message: 'Koneksi AI sedang bermasalah. Coba lagi nanti ya.',
      statusCode: 502,
      code: 'auth_failed',
    });
  }

  if (status === 404 && normalizedBody.includes('no longer available')) {
    return new AiServiceError({
      message: 'Model AI yang dipakai backend sudah tidak tersedia.',
      statusCode: 502,
      code: 'model_unavailable',
    });
  }

  if (status === 429) {
    return new AiServiceError({
      message: 'Syra lagi ramai sebentar. Coba lagi pelan-pelan ya.',
      statusCode: 429,
      code: 'rate_limited',
    });
  }

  return new AiServiceError({
    message: 'Syra belum bisa membalas sekarang.',
    statusCode: 502,
    code: 'provider_error',
  });
}

module.exports = {
  AiServiceError,
  generateSyraReply,
};
