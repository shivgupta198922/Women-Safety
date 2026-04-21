const express = require('express');
const router = express.Router();
const User = require('../models/User');
const auth = require('../middleware/auth');

// Update last location
router.post('/update', auth, async (req, res) => {
  try {
    const { lat, lng } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { 
        lastLocation: { lat, lng, timestamp: new Date() }
      },
      { new: true }
    ).select('-password');
    res.json(user.lastLocation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get last location
router.get('/', auth, async (req, res) => {
  const user = await User.findById(req.user.id).select('lastLocation');
  res.json(user.lastLocation || {});
});

module.exports = router;
