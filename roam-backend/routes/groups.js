const express = require('express');
const pool = require('../db');
const auth = require('../middleware/auth');
const router = express.Router();

// Create a new group
router.post('/', auth, async (req, res) => {
  try {
    const { name, description, is_public } = req.body;
    const newGroup = await pool.query(
      'INSERT INTO groups (name, description, is_public) VALUES ($1, $2, $3) RETURNING *',
      [name, description, is_public]
    );
    // Make the creator an admin of the group
    await pool.query(
      'INSERT INTO user_groups (user_id, group_id, is_admin) VALUES ($1, $2, $3)',
      [req.user.id, newGroup.rows[0].id, true]
    );
    res.status(201).json(newGroup.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get all public groups
router.get('/public', auth, async (req, res) => {
  try {
    const publicGroups = await pool.query('SELECT * FROM groups WHERE is_public = true');
    res.json(publicGroups.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Join a group
router.post('/join/:groupId', auth, async (req, res) => {
  try {
    const { groupId } = req.params;
    const group = await pool.query('SELECT * FROM groups WHERE id = $1', [groupId]);
    if (group.rows.length === 0) {
      return res.status(404).json({ message: "Group not found" });
    }
    if (!group.rows[0].is_public) {
      return res.status(403).json({ message: "This group is private" });
    }
    await pool.query(
      'INSERT INTO user_groups (user_id, group_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.user.id, groupId]
    );
    res.json({ message: "Successfully joined the group" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// Get user's groups
router.get('/my', auth, async (req, res) => {
  try {
    const userGroups = await pool.query(
      'SELECT g.* FROM groups g JOIN user_groups ug ON g.id = ug.group_id WHERE ug.user_id = $1',
      [req.user.id]
    );
    res.json(userGroups.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
