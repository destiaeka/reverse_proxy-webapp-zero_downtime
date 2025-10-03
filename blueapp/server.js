const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = 3000;

// Koneksi database PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'products',
  port: process.env.DB_PORT || 5432,
});

// Middleware
app.use(express.json());

// Serve static
app.use('/static', express.static(path.join(__dirname, 'views')));

// Endpoint Selamat Datang
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

// Endpoint Product (ambil dari DB)
app.get('/product', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    let html = `<h1>Daftar Produk</h1><ul>`;
    result.rows.forEach(p => {
      html += `<li>${p.name} - Rp${p.price}</li>`;
    });
    html += `</ul>`;
    res.send(html);
  } catch (err) {
    console.error(err);
    res.status(500).send('Gagal ambil data produk');
  }
});

// Endpoint API JSON product
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Gagal ambil data produk' });
  }
});

app.listen(PORT, () => console.log(`App running on port ${PORT}`));
