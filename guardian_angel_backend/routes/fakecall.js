const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// Log fake call activation
router.post('/', auth, async (req, res) => {
  try {
    const { callerName, callerPhoto, duration, timerScheduled } = req.body;
    
    // Log to alerts or separate logs
    const log = {
      userId: req.user.id,
      type: 'fake_call',
      callerName,
      callerPhoto,
      duration,
      timerScheduled,
      location: req.body.location // optional
    };

    // Could save to Alert model or dedicated FakeCallLog
    res.status(201).json({ success: true, log });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get fake call history
router.get('/', auth, async (req, res) => {
  try {
    // Query alerts with type 'fake_call' or dedicated model
    const history = []; // placeholder
    res.json(history);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

