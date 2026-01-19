const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const ENV = process.env.ENVIRONMENT || 'dev';

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    environment: ENV,
    timestamp: new Date().toISOString()
  });
});

app.get('/dados', (req, res) => {
  res.json({
    message: 'Dados do backend dummy',
    environment: ENV,
    data: {
      usuarios: [
        { id: 1, nome: 'João Silva', email: 'joao@example.com' },
        { id: 2, nome: 'Maria Santos', email: 'maria@example.com' },
        { id: 3, nome: 'Pedro Oliveira', email: 'pedro@example.com' }
      ],
      produtos: [
        { id: 1, nome: 'Produto A', preco: 100.00 },
        { id: 2, nome: 'Produto B', preco: 200.00 },
        { id: 3, nome: 'Produto C', preco: 300.00 }
      ]
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({
    service: 'Backend Dummy API',
    version: '1.0.0',
    environment: ENV,
    endpoints: [
      'GET /health - Health check',
      'GET /dados - Retorna dados dummy',
      'GET / - Esta mensagem'
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend rodando na porta ${PORT} - Ambiente: ${ENV}`);
});
