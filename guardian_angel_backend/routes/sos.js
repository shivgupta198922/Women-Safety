const express = require('express');
const router = express.Router();
const Alert = require('../models/Alert');
const Contact = require('../models/Contact');
const auth = require('../middleware/auth');

// Create SOS alert (called from frontend)
// @route   POST api/sos/send
// @desc    Send an SOS alert
// @access  Private
router.post('/send', auth, async (req, res) => {
  try {
    const { type, location, message, audioRecordingUrl, videoRecordingUrl } = req.body; // Accept both recording URLs
    const alert = new Alert({
      user: req.user.id,
      type,
      location,
      message,
      audioRecordingUrl,
      videoRecordingUrl
    });
    await alert.save();

    // Fetch emergency contacts for the user
    const emergencyContacts = await Contact.find({ user: req.user.id, isEmergency: true }).select('name phoneNumber email');
    console.log(`SOS triggered by user ${req.user.id}. Notifying contacts:`, emergencyContacts);

    // TODO: Implement actual notification logic here:
    // 1. Send SMS to emergencyContacts.phoneNumber
    // 2. Send Email to emergencyContacts.email
    // 3. Send Push Notification (FCM) to emergency contacts' devices
    // 4. Emit real-time alert via Socket.IO to connected emergency contacts (if they are also app users)
    //    The client (Flutter app) also emits 'sendSOS' directly to Socket.IO for immediate real-time updates.
    //    This backend route primarily logs the alert and can trigger server-side notifications.

    res.status(201).json(alert);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// @route   GET api/sos
// @desc    Get all user's SOS alerts
// @access  Private
router.get('/', auth, async (req, res) => { // Added a GET route for alerts
  const alerts = await Alert.find({ user: req.user.id }).sort({ createdAt: -1 });
  res.json(alerts);
});

module.exports = router;
