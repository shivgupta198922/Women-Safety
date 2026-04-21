const express = require('express');
const router = express.Router();
const Alert = require('../models/Alert');
const auth = require('../middleware/auth');

// Create SOS alert (called from frontend)
router.post('/', auth, async (req, res) => {
  try {
    const { type, location, message, recordingUrl } = req.body;
    const alert = new Alert({
      userId: req.user.id,
      type,
      location,
      message,
      recordingUrl
    });
    await alert.save();
    // Emit via socket in server.js
    res.status(201).json(alert);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/', auth, async (req, res) => {
  const alerts = await Alert.find({ userId: req.user.id }).sort({ createdAt: -1 });
  res.json(alerts);
});

module.exports = router;
