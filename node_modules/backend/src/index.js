const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';
const origins = (process.env.FRONTEND_ORIGINS || 'http://localhost:5173').split(',');

app.use(cors({ origin: origins }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/compare', (req, res) => {
  res.json({
    message: 'API de comparação funcionando!',
    items: []
  });
});

app.listen(PORT, HOST, () => {
  console.log(`Backend rodando em http://${HOST}:${PORT}`);
});
