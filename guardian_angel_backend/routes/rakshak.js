const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

// Toggle Rakshak mode
router.post('/toggle', auth, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: { 'settings.rakshakMode': req.body.enabled } },
      { new: true }
    );
    res.json({ success: true, rakshakMode: user.settings.rakshakMode });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Rakshak status
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('settings.rakshakMode');
    res.json({ rakshakMode: user.settings.rakshakMode });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

