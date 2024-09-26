require('dotenv').config();
const express = require('express');
const userRoutes = require('./routes/users');
const carpoolRoutes = require('./routes/carpools');
const groupRoutes = require('./routes/groups');
const pool = require('./db');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.use('/api/users', userRoutes);
app.use('/api/carpools', carpoolRoutes);
app.use('/api/groups', groupRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Roam API' });
});

// Database test route
app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ message: 'Database connected successfully', time: result.rows[0].now });
  } catch (err) {
    console.error('Database connection error:', err);
    res.status(500).json({ error: 'Database connection failed', details: err.message });
  }
});

console.log('JWT_SECRET:', process.env.JWT_SECRET);

// Start server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
