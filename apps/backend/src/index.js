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

const { scrapeMercadoLivre, scrapeAmazon, scrapeMagalu, scrapeGeneric } = require('./scraper');

app.get('/api/compare', async (req, res) => {
  const targetUrl = req.query.url;

  if (!targetUrl) {
    return res.status(400).json({ error: 'URL parameter is required' });
  }

  let scrapedData = null;

  try {
    if (targetUrl.includes('mercadolivre.com')) {
      console.log('Scraping Mercado Livre...');
      scrapedData = await scrapeMercadoLivre(targetUrl);
    } else if (targetUrl.includes('amazon.com')) {
      console.log('Scraping Amazon...');
      scrapedData = await scrapeAmazon(targetUrl);
    } else if (targetUrl.includes('magazineluiza.com.br')) {
      console.log('Scraping Magazine Luiza...');
      scrapedData = await scrapeMagalu(targetUrl);
    } else {
      console.log('Scraping Generico...');
      scrapedData = await scrapeGeneric(targetUrl);
    }

    if (scrapedData) {
        // Retorna apenas o item real rasurado. Sem concorrentes falsos.
        res.json({
            message: 'Análise concluída',
            items: [scrapedData]
        });
    } else {
        res.status(500).json({ error: 'Failed to scrape data from URL' });
    }

  } catch (err) {
      console.error('Error during comparison:', err);
      res.status(500).json({ error: 'Internal server error during scraping' });
  }
});

app.listen(PORT, HOST, () => {
  console.log(`Backend rodando em http://${HOST}:${PORT}`);
});
