const { loadBackendEnv } = require('./loadEnv');

const cors = require('cors');
const express = require('express');

const chatRouter = require('./routes/chat');

loadBackendEnv();

const app = express();
const port = Number(process.env.PORT || 3000);
const corsOrigin = process.env.CORS_ORIGIN || '*';

app.use(
  cors({
    origin: corsOrigin === '*' ? true : corsOrigin,
  }),
);
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'formisra-backend',
  });
});

app.use('/api/chat', chatRouter);

app.listen(port, () => {
  console.log(`Formisra backend berjalan di http://localhost:${port}`);
});
