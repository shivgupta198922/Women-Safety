const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Contact = require('../models/Contact');
const auth = require('../middleware/auth');

// Get profile
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update profile
router.put('/profile', auth, async (req, res) => {
  try {
    const updates = req.body;
    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true }).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Emergency contacts CRUD
router.get('/contacts', auth, async (req, res) => {
  const contacts = await Contact.find({ userId: req.user.id });
  res.json(contacts);
});

router.post('/contacts', auth, async (req, res) => {
  const contact = new Contact({ ...req.body, userId: req.user.id });
  await contact.save();
  res.status(201).json(contact);
});

router.put('/contacts/:id', auth, async (req, res) => {
  const contact = await Contact.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.id },
    req.body,
    { new: true }
  );
  if (!contact) return res.status(404).json({ error: 'Contact not found' });
  res.json(contact);
});

router.delete('/contacts/:id', auth, async (req, res) => {
  const contact = await Contact.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
  if (!contact) return res.status(404).json({ error: 'Contact not found' });
  res.json({ message: 'Contact deleted' });
});

module.exports = router;
