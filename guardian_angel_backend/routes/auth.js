const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { check, validationResult } = require('express-validator');
const auth = require('../middleware/auth');

const ACCOUNT_TYPES = ['individual', 'parent', 'child', 'hospital', 'police', 'council', 'guardian'];

function sanitizeUser(user) {
  const data = user.toObject ? user.toObject() : user;
  delete data.password;
  return data;
}

function normalizeIdentifier(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function buildToken(userId) {
  return jwt.sign({ user: { id: userId } }, process.env.JWT_SECRET, { expiresIn: '5h' });
}

router.get('/account-types', (req, res) => {
  res.json({
    accountTypes: ACCOUNT_TYPES.map((id) => ({
      id,
      label: id.charAt(0).toUpperCase() + id.slice(1),
    })),
  });
});

router.post(
  '/register',
  [
    check('fullName', 'Full name is required').not().isEmpty(),
    check('phoneNumber', 'Phone number is required').not().isEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Please enter a password with 6 or more characters').isLength({ min: 6 }),
    check('accountType').optional().isIn(ACCOUNT_TYPES),
  ],
  async (req, res) => {
  try {
    if (typeof req.body.phoneNumber !== 'string' && typeof req.body.phone === 'string') {
      req.body.phoneNumber = req.body.phone;
    }

    if (typeof req.body.fullName !== 'string' && typeof req.body.name === 'string') {
      req.body.fullName = req.body.name;
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      fullName,
      email,
      phoneNumber,
      password,
      accountType = 'individual',
      organizationName,
      departmentName,
      securePairing,
    } = req.body;

    const normalizedEmail = email.trim().toLowerCase();
    const normalizedPhoneNumber = phoneNumber.trim();

    let user = await User.findOne({
      $or: [
        { email: normalizedEmail },
        { phoneNumber: normalizedPhoneNumber },
      ],
    });
    if (user) {
      const duplicateField = user.email === normalizedEmail ? 'email' : 'phone number';
      return res.status(400).json({ msg: `User already exists with this ${duplicateField}` });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    user = new User({
      fullName: fullName.trim(),
      email: normalizedEmail,
      phoneNumber: normalizedPhoneNumber,
      password: hashedPassword,
      accountType,
      organizationName: organizationName?.trim(),
      departmentName: departmentName?.trim(),
      securePairing: {
        pairingCode: securePairing?.pairingCode,
        targetPairingCode: securePairing?.targetPairingCode,
        pairingStatus: securePairing?.pairingStatus || 'unpaired',
        devicePublicKey: securePairing?.devicePublicKey,
        accessPermissions: {
          notifications: securePairing?.accessPermissions?.notifications !== false,
          liveLocation: securePairing?.accessPermissions?.liveLocation !== false,
          camera: securePairing?.accessPermissions?.camera === true,
          microphone: securePairing?.accessPermissions?.microphone === true,
        },
      },
    });
    await user.save();
    
    const token = buildToken(user._id);
    res.status(201).json({
      message: 'Registration successful',
      token,
      user: sanitizeUser(user),
    });
  } catch (err) {
    console.error(err.message);
    if (err.code === 11000) {
      const duplicateField = Object.keys(err.keyPattern || {})[0] || 'field';
      return res.status(400).json({ msg: `Duplicate value for ${duplicateField}` });
    }
    res.status(500).send('Server error');
  }
});

router.post(
  '/login',
  [
    check('password', 'Password is required').not().isEmpty(),
  ],
  async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const identifier = normalizeIdentifier(req.body.identifier || req.body.email || req.body.phoneNumber || req.body.phone);
    const password = req.body.password;
    const accountType = normalizeIdentifier(req.body.accountType);

    if (!identifier) {
      return res.status(400).json({ error: 'Email or phone number is required' });
    }

    const identifierQuery = identifier.includes('@')
      ? { email: identifier.toLowerCase() }
      : { phoneNumber: identifier };

    const query = accountType ? { ...identifierQuery, accountType } : identifierQuery;
    const user = await User.findOne(query);
    if (!user || !await bcrypt.compare(password, user.password)) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    
    const token = buildToken(user._id);
    res.json({
      message: 'Login successful',
      token,
      user: sanitizeUser(user),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// @route   GET api/auth/me
// @desc    Get logged in user
// @access  Private
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
