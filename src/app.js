const express = require('express');
const pool = require('./config/db');

const app = express();

app.use(express.json());

// Ruta temporal para comprobar la conexión a la base de datos
app.get('/api/health', async (req, res) => {
  try {
    const resultado = await pool.query('SELECT NOW() AS hora');
    res.status(200).json({ estado: 'ok', hora_bd: resultado.rows[0].hora });
  } catch (error) {
    console.error(error);
    res.status(500).json({ estado: 'error', mensaje: 'No se pudo conectar a la base de datos' });
  }
});

module.exports = app;