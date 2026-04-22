const express = require('express');
const router = express.Router();
const Alert = require('../models/Alert');
const Contact = require('../models/Contact');
const User = require('../models/User');
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

    const io = req.app.get('socketio');
    const sender = await User.findById(req.user.id).select('fullName accountType securePairing');
    const recipientIds = new Set();

    const contactPhones = emergencyContacts
      .map((contact) => contact.phoneNumber?.trim())
      .filter(Boolean);
    const contactEmails = emergencyContacts
      .map((contact) => contact.email?.trim()?.toLowerCase())
      .filter(Boolean);

    if (contactPhones.length > 0 || contactEmails.length > 0) {
      const matchedUsers = await User.find({
        $or: [
          ...(contactPhones.length > 0 ? [{ phoneNumber: { $in: contactPhones } }] : []),
          ...(contactEmails.length > 0 ? [{ email: { $in: contactEmails } }] : []),
        ],
      }).select('_id');

      matchedUsers.forEach((user) => recipientIds.add(user._id.toString()));
    }

    const targetPairingCode = sender?.securePairing?.targetPairingCode?.trim();
    const ownPairingCode = sender?.securePairing?.pairingCode?.trim();

    if (sender?.accountType === 'child' && targetPairingCode) {
      const parentOrGuardian = await User.findOne({
        accountType: { $in: ['parent', 'guardian'] },
        'securePairing.pairingCode': targetPairingCode,
      }).select('_id');

      if (parentOrGuardian) {
        recipientIds.add(parentOrGuardian._id.toString());
      }
    }

    if (sender && ['parent', 'guardian'].includes(sender.accountType) && ownPairingCode) {
      const children = await User.find({
        accountType: 'child',
        'securePairing.targetPairingCode': ownPairingCode,
      }).select('_id');

      children.forEach((child) => recipientIds.add(child._id.toString()));
    }

    for (const recipientId of recipientIds) {
      if (recipientId === req.user.id.toString()) continue;

      io.to(recipientId).emit('receiveSOS', {
        senderId: req.user.id,
        senderName: sender?.fullName || 'A user',
        senderAccountType: sender?.accountType,
        message: `Emergency alert from ${sender?.fullName || 'a user'}!`,
        location,
        type,
        audioRecordingUrl,
        videoRecordingUrl,
      });
    }

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
