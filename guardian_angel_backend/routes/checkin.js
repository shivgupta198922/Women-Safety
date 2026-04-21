const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const CheckInSession = require('../models/CheckInSession');
const User = require('../models/User');

// Create check-in session
router.post('/', auth, async (req, res) => {
  try {
    const { durationMinutes, watchers } = req.body;
    const expiresAt = new Date(Date.now() + durationMinutes * 60 * 1000);
    
    const session = new CheckInSession({
      userId: req.user.id,
      expiresAt,
      watchers
    });
    await session.save();
    
    // Notify watchers via socket/FCM
    res.status(201).json(session);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Respond to check-in
router.post('/:id/respond', auth, async (req, res) => {
  try {
    const { status } = req.body; // safe/unsafe
    const session = await CheckInSession.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { responseStatus: status },
      { new: true }
    );
    if (!session) return res.status(404).json({ error: 'Session not found' });
    
    if (status === 'unsafe') {
      // Trigger SOS
    }
    
    res.json(session);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get active check-ins
router.get('/', auth, async (req, res) => {
  try {
    const sessions = await CheckInSession.find({ 
      userId: req.user.id,
      responseStatus: 'pending'
    });
    res.json(sessions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

