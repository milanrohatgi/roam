const express = require('express');
const pool = require('../db');
const auth = require('../middleware/auth');
const router = express.Router();

// Create a new carpool request
router.post('/', auth, async (req, res) => {
  try {
    console.log('Create carpool request body:', req.body);
    console.log('User from auth middleware:', req.user);

    const { group_id, title, description, origin, destination, date_time, is_anonymous } = req.body;
    
    if (!req.user || !req.user.id) {
      console.error('User ID not found in request');
      return res.status(400).json({ error: 'User ID is required' });
    }

    const user_id = req.user.id;
    
    const query = `
      INSERT INTO carpool_requests 
      (user_id, group_id, title, description, origin, destination, date_time, is_anonymous, status) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
      RETURNING *
    `;
    const values = [user_id, group_id, title, description, origin, destination, date_time, is_anonymous, 'open'];
    
    console.log('Executing query:', query);
    console.log('Query values:', values);

    const newCarpool = await pool.query(query, values);
    console.log('New carpool created:', newCarpool.rows[0]);

    res.status(201).json(newCarpool.rows[0]);
  } catch (err) {
    console.error('Error in create carpool:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});
router.get('/group-carpools', auth, async (req, res) => {
  try {
    const user_id = req.user.id;
    console.log(`Fetching carpools for groups of user ${user_id}`);

    const query = `
      SELECT DISTINCT cr.* 
      FROM carpool_requests cr
      JOIN user_groups ug ON cr.group_id = ug.group_id
      WHERE ug.user_id = $1
      ORDER BY cr.date_time DESC
    `;
    const carpools = await pool.query(query, [user_id]);
    console.log(`Found ${carpools.rows.length} carpools for user's groups`);

    res.json(carpools.rows);
  } catch (err) {
    console.error('Error fetching group carpools:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});


// Get all carpool requests for a group
router.get('/group/:groupId', auth, async (req, res) => {
  try {
    const { groupId } = req.params;
    console.log(`Fetching carpools for group: ${groupId}`);

    const carpools = await pool.query('SELECT * FROM carpool_requests WHERE group_id = $1', [groupId]);
    console.log(`Found ${carpools.rows.length} carpools for group ${groupId}`);

    res.json(carpools.rows);
  } catch (err) {
    console.error('Error fetching group carpools:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Get a specific carpool request
router.get('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`Fetching carpool with id: ${id}`);

    const carpool = await pool.query('SELECT * FROM carpool_requests WHERE id = $1', [id]);
    if (carpool.rows.length === 0) {
      console.log(`Carpool with id ${id} not found`);
      return res.status(404).json({ message: "Carpool request not found" });
    }
    
    const participants = await pool.query(
      'SELECT u.id, u.name, u.email FROM users u JOIN carpool_participants cp ON u.id = cp.user_id WHERE cp.carpool_id = $1',
      [id]
    );
    
    console.log(`Carpool ${id} found with ${participants.rows.length} participants`);
    res.json({...carpool.rows[0], participants: participants.rows});
  } catch (err) {
    console.error('Error fetching specific carpool:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Join a carpool
router.post('/:id/join', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const user_id = req.user.id;
    console.log(`User ${user_id} attempting to join carpool ${id}`);

    const carpool = await pool.query('SELECT * FROM carpool_requests WHERE id = $1 AND status = $2', [id, 'open']);
    if (carpool.rows.length === 0) {
      console.log(`Carpool ${id} not found or not open`);
      return res.status(404).json({ message: "Carpool request not found or is not open" });
    }

    await pool.query('INSERT INTO carpool_participants (carpool_id, user_id) VALUES ($1, $2)', [id, user_id]);
    console.log(`User ${user_id} successfully joined carpool ${id}`);

    res.json({ message: "Successfully joined the carpool" });
  } catch (err) {
    console.error('Error joining carpool:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Get user's rides (both as owner and participant)
router.get('/my/rides', auth, async (req, res) => {
  try {
    const user_id = req.user.id;
    console.log(`Fetching rides for user ${user_id}`);

    const query = `
      SELECT cr.* FROM carpool_requests cr 
      WHERE cr.user_id = $1
      UNION
      SELECT cr.* FROM carpool_requests cr
      JOIN carpool_participants cp ON cr.id = cp.carpool_id
      WHERE cp.user_id = $1
    `;
    const rides = await pool.query(query, [user_id]);
    console.log(`Found ${rides.rows.length} rides for user ${user_id}`);

    res.json(rides.rows);
  } catch (err) {
    console.error('Error fetching user rides:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Update carpool status (only by owner)
router.put('/:id/status', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const user_id = req.user.id;
    console.log(`User ${user_id} attempting to update status of carpool ${id} to ${status}`);

    const updateCarpool = await pool.query(
      'UPDATE carpool_requests SET status = $1 WHERE id = $2 AND user_id = $3 RETURNING *',
      [status, id, user_id]
    );

    if (updateCarpool.rows.length === 0) {
      console.log(`Update failed: Carpool ${id} not found or user ${user_id} not authorized`);
      return res.status(404).json({ message: "Carpool request not found or you're not authorized to update it" });
    }

    console.log(`Carpool ${id} status updated to ${status}`);
    res.json(updateCarpool.rows[0]);
  } catch (err) {
    console.error('Error updating carpool status:', err);
    console.error('Error details:', err.message);
    console.error('Error stack:', err.stack);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

module.exports = router;
