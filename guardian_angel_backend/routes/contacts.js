const express = require('express');
const router = express.Router();
const Contact = require('../models/Contact');
const { check, validationResult } = require('express-validator'); // Import check and validationResult
const User = require('../models/User');
const auth = require('../middleware/auth');

// Get all contacts
router.get('/', auth, async (req, res) => {
  try {
    const contacts = await Contact.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json(contacts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// @route   POST api/contacts/add
// @desc    Add new emergency contact
// @access  Private
router.post(
  '/', // Changed route from '/add' to '/'
  [
    auth,
    check('name', 'Name is required').not().isEmpty(),
    check('phoneNumber', 'Phone number is required').not().isEmpty(),
  ],
  async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, phoneNumber, email, relationship, isEmergency } = req.body;
    const contact = new Contact({
      user: req.user.id,
      name,
      phoneNumber,
      email,
      relationship,
      isEmergency: isEmergency ?? true, // Default to emergency contact
    });
    await contact.save();
    res.status(201).json(contact);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   PUT api/contacts/:id
// @desc    Update an emergency contact
// @access  Private
router.put(
  '/:id',
  [
    auth,
    [
      check('name', 'Name is required').not().isEmpty(),
      check('phoneNumber', 'Phone number is required').not().isEmpty(),
    ],
  ],
  async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, phoneNumber, email, relationship, isEmergency } = req.body;

    const contact = await Contact.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { name, phoneNumber, email, relationship, isEmergency },
      { new: true }
    );
    if (!contact) return res.status(404).json({ error: 'Contact not found' });
    res.json(contact);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   DELETE api/contacts/:id
// @desc    Delete an emergency contact
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const contact = await Contact.findOneAndDelete({ _id: req.params.id, user: req.user.id });
    if (!contact) return res.status(404).json({ error: 'Contact not found' });
    res.json({ message: 'Contact deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET api/contacts/emergency
// @desc    Get all user emergency contacts
// @access  Private
router.get('/emergency', auth, async (req, res) => {
  try {
    const contacts = await Contact.find({ user: req.user.id, isEmergency: true }).sort({ createdAt: -1 });
    res.json(contacts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
