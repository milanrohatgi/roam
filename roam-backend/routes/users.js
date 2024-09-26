const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const nodemailer = require('nodemailer');

const router = express.Router();

// Configure nodemailer (replace with your email service details)
const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  auth: {
    user: 'your-email@example.com',
    pass: 'your-password'
  }
});

// User registration
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    if (!email.endsWith('@stanford.edu')) {
      return res.status(400).json({ error: 'Only stanford.edu email addresses are allowed' });
    }

    const userExists = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const newUser = await pool.query(
      'INSERT INTO users (email, password, name, verification_code, is_verified) VALUES ($1, $2, $3, $4, $5) RETURNING id, email, name',
      [email, hashedPassword, name, verificationCode, false]
    );

    // Send verification email
    await sendVerificationEmail(email, verificationCode);

    res.status(201).json({ message: 'User registered. Please check your email for verification.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Email verification
router.post('/verify', async (req, res) => {
  try {
    const { email, verificationCode } = req.body;

    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    if (user.rows[0].verification_code !== verificationCode) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    await pool.query('UPDATE users SET is_verified = true WHERE email = $1', [email]);

    res.json({ message: 'Email verified successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// User login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    if (!user.rows[0].is_verified) {
      return res.status(400).json({ error: 'Email not verified' });
    }

    const validPassword = await bcrypt.compare(password, user.rows[0].password);
    if (!validPassword) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.rows[0].id }, process.env.JWT_SECRET);
    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Forgot password
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    await pool.query('UPDATE users SET reset_code = $1 WHERE email = $2', [resetCode, email]);

    await sendPasswordResetEmail(email, resetCode);

    res.json({ message: 'Password reset instructions sent to your email' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Reset password
router.post('/reset-password', async (req, res) => {
  try {
    const { email, resetCode, newPassword } = req.body;

    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    if (user.rows[0].reset_code !== resetCode) {
      return res.status(400).json({ error: 'Invalid reset code' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await pool.query('UPDATE users SET password = $1, reset_code = NULL WHERE email = $2', [hashedPassword, email]);

    res.json({ message: 'Password reset successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Helper function to send verification email
async function sendVerificationEmail(email, verificationCode) {
  await transporter.sendMail({
    from: '"Roam App" ',
    to: email,
    subject: "Verify your email for Roam App",
    text: `Your verification code is: ${verificationCode}`,
    html: `Your verification code is: ${verificationCode}`,
  });
}

// Helper function to send password reset email
async function sendPasswordResetEmail(email, resetCode) {
  await transporter.sendMail({
    from: '"Roam App" ',
    to: email,
    subject: "Reset your password for Roam App",
    text: `Your password reset code is: ${resetCode}`,
    html: `Your password reset code is: ${resetCode}`,
  });
}

module.exports = router;
