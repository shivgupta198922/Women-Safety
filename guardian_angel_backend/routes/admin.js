const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Alert = require('../models/Alert');
const auth = require('../middleware/auth');

// Middleware for admin only
const adminAuth = (req, res, next) => {
  if (!req.user.isAdmin) return res.status(403).json({ error: 'Admin access required' });
  next();
};

// Get all users
router.get('/users', auth, adminAuth, async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
});

// Get all alerts
router.get('/alerts', auth, adminAuth, async (req, res) => {
  const alerts = await Alert.find().populate('userId', 'name phone');
  res.json(alerts);
});

// Dashboard stats
router.get('/stats', auth, adminAuth, async (req, res) => {
  const userCount = await User.countDocuments();
  const alertCount = await Alert.countDocuments({ status: 'pending' });
  res.json({ userCount, alertCount });
});

module.exports = router;
