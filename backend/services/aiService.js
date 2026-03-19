const { syraSystemPrompt } = require('../prompts/syraPrompt');

const MAX_HISTORY_MESSAGES = 4;
const MAX_MESSAGE_CHARS = 280;
const MAX_OUTPUT_TOKENS = 180;

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

function mapHistoryToMessages(history) {
  if (!Array.isArray(history)) {
    return [];
  }

  return history
    .filter((item) => item && typeof item.text === 'string' && item.text.trim())
    .slice(-MAX_HISTORY_MESSAGES)
    .map((item) => ({
      role: item.role === 'assistant' ? 'assistant' : 'user',
      content: normalizeMessageText(item.text),
    }));
}

function getAiProvider() {
  if (process.env.AI_PROVIDER) {
    return String(process.env.AI_PROVIDER).trim().toLowerCase();
  }

  if (process.env.OPENROUTER_API_KEY) {
    return 'openrouter';
  }

  if (process.env.GEMINI_API_KEY) {
    return 'gemini';
  }

  return 'openrouter';
}

async function generateSyraReply({ message, history = [] }) {
  const normalizedMessage = normalizeMessageText(message);

  if (!normalizedMessage) {
    throw new AiServiceError({
      message: 'Pesan wajib diisi.',
      statusCode: 400,
      code: 'empty_message',
    });
  }

  const provider = getAiProvider();

  if (provider === 'gemini') {
    return generateGeminiReply({
      message: normalizedMessage,
      history,
    });
  }

  return generateOpenRouterReply({
    message: normalizedMessage,
    history,
  });
}

async function generateOpenRouterReply({ message, history = [] }) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  const model = process.env.OPENROUTER_MODEL;

  if (!apiKey) {
    throw new AiServiceError({
      message: 'Backend belum siap untuk membalas chat sekarang.',
      statusCode: 500,
      code: 'missing_api_key',
    });
  }

  if (!model) {
    throw new AiServiceError({
      message: 'Model AI backend belum diatur.',
      statusCode: 500,
      code: 'missing_model',
    });
  }

  const appName = process.env.OPENROUTER_APP_NAME || 'Formisra';
  const siteUrl = getOpenRouterSiteUrl();

  const response = await fetch(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
        'X-Title': appName,
        ...(siteUrl ? { 'HTTP-Referer': siteUrl } : {}),
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: syraSystemPrompt,
          },
          ...mapHistoryToMessages(history),
          {
            role: 'user',
            content: message,
          },
        ],
        max_tokens: MAX_OUTPUT_TOKENS,
        temperature: 0.8,
        top_p: 0.9,
      }),
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();
    throw mapOpenRouterError(response.status, errorBody);
  }

  const data = await response.json();
  const reply = normalizeOpenRouterReply(data.choices?.[0]?.message?.content);

  if (!reply) {
    throw new AiServiceError({
      message: 'Syra belum bisa membalas sekarang.',
      statusCode: 502,
      code: 'empty_ai_reply',
    });
  }

  return reply;
}

async function generateGeminiReply({ message, history = [] }) {
  const apiKey = process.env.GEMINI_API_KEY;
  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite';

  if (!apiKey) {
    throw new AiServiceError({
      message: 'Backend belum siap untuk membalas chat sekarang.',
      statusCode: 500,
      code: 'missing_api_key',
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
                text: message,
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: MAX_OUTPUT_TOKENS,
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

function getOpenRouterSiteUrl() {
  const candidates = [
    process.env.OPENROUTER_SITE_URL,
    process.env.APP_URL,
    process.env.CORS_ORIGIN,
  ];

  const validCandidate = candidates.find(
    (value) => typeof value === 'string' && value.trim() && value.trim() !== '*',
  );

  return validCandidate ? validCandidate.trim() : '';
}

function normalizeOpenRouterReply(content) {
  if (typeof content === 'string') {
    return content.trim();
  }

  if (!Array.isArray(content)) {
    return '';
  }

  return content
    .map((item) => (item && typeof item.text === 'string' ? item.text : ''))
    .filter(Boolean)
    .join('')
    .trim();
}

function mapOpenRouterError(status, errorBody) {
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

  if (status === 404 || normalizedBody.includes('No endpoints found')) {
    return new AiServiceError({
      message: 'Model AI yang dipakai backend sudah tidak tersedia.',
      statusCode: 502,
      code: 'model_unavailable',
    });
  }

  if (status === 429) {
    return new AiServiceError({
      message: 'Syra lagi banyak yang manggil sebentar, coba lagi yaa.',
      statusCode: 429,
      code: 'rate_limited',
    });
  }

  if (status === 402) {
    return new AiServiceError({
      message: 'Provider AI sedang membatasi akses model sekarang.',
      statusCode: 502,
      code: 'provider_limited',
    });
  }

  return new AiServiceError({
    message: 'Syra belum bisa membalas sekarang.',
    statusCode: 502,
    code: 'provider_error',
  });
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
      message: 'Syra lagi banyak yang manggil sebentar, coba lagi yaa.',
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
