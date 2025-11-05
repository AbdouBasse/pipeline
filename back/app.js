const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const client = require('prom-client');
const connectDB = require('./connectdb');
const smartphoneRoutes = require('./routes/smartphoneRoutes');

dotenv.config();
connectDB();

const app = express();
app.use(cors({ origin: '*', credentials: true }));
app.use(express.json({ limit: "10mb" }));

// 🔁 Compteur de requêtes HTTP
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Nombre total de requêtes HTTP',
  labelNames: ['method', 'route', 'status']
});

app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status: res.statusCode
    });
  });
  next();
});

// 🔍 Route /metrics
client.collectDefaultMetrics();
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Routes API
app.use('/api', smartphoneRoutes);

// Lancement
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Serveur lancé sur http://0.0.0.0:${PORT}`));
