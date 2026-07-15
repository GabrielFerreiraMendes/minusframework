const express = require('express');
const crypto = require('crypto');
const fs = require('fs');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3456;

// Carrega a chave privada (gerada por generate-keys.js)
const PRIVATE_KEY = fs.readFileSync('private.pem', 'utf8');

// Tiers validos
const TIERS = ['FREE', 'PRO', 'ENTERPRISE'];

// Audit log em memoria (substituir por banco em producao)
const issuedKeys = [];

app.post('/license/generate', (req, res) => {
  const { tier, customer, email, expires } = req.body;

  // Validacoes
  if (!TIERS.includes(tier?.toUpperCase())) {
    return res.status(400).json({ error: `Tier invalido. Use: ${TIERS.join(', ')}` });
  }
  if (!customer || customer.length < 3) {
    return res.status(400).json({ error: 'customer deve ter ao menos 3 caracteres' });
  }
  if (!expires) {
    return res.status(400).json({ error: 'expires e obrigatorio (YYYY-MM-DD)' });
  }

  const payload = {
    tier: tier.toUpperCase(),
    customer,
    email: email || '',
    expires,
    issued: new Date().toISOString().split('T')[0]
  };

  const json = JSON.stringify(payload);
  const signature = crypto.sign('sha256', Buffer.from(json), PRIVATE_KEY);
  const key = Buffer.from(json).toString('base64url') + '.' + signature.toString('base64url');

  issuedKeys.push({ ...payload, key });

  res.json({
    key,
    payload,
    instructions: `Use esta key no licenciamento do MinusFrameWork`
  });
});

app.get('/license/health', (req, res) => {
  res.json({ status: 'ok', keysIssued: issuedKeys.length });
});

app.listen(PORT, () => {
  console.log(`MinusFrameWork License Server rodando em http://localhost:${PORT}`);
});
