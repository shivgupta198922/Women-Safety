const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Journey = require('../models/Journey');
const CheckIn = require('../models/CheckIn');
const Contact = require('../models/Contact');
const User = require('../models/User');

// @route   POST /api/journey/start
// @desc    Start a new safe journey
// @access  Private
router.post('/start', auth, async (req, res) => {
  const { watchers, startLocation, endLocation, checkInIntervalMinutes } = req.body;

  try {
    // Deactivate any existing active journeys for this user
    await Journey.updateMany({ user: req.user.id, isActive: true }, { isActive: false, endTime: Date.now() });

    const nextCheckInTime = new Date(Date.now() + checkInIntervalMinutes * 60 * 1000);

    const newJourney = new Journey({
      user: req.user.id,
      watchers, // Array of Contact IDs
      startLocation,
      endLocation,
      checkInIntervalMinutes,
      nextCheckInTime,
      isActive: true,
    });

    const journey = await newJourney.save();

    // TODO: Notify watchers via Socket.IO/SMS that a journey has started
    // You might want to fetch watcher details (phone numbers) from the Contact model

    res.status(201).json(journey);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   POST /api/journey/:id/checkin
// @desc    User checks in during a journey
// @access  Private
router.post('/:id/checkin', auth, async (req, res) => {
  try {
    const journey = await Journey.findOne({ _id: req.params.id, user: req.user.id, isActive: true });
    if (!journey) {
      return res.status(404).json({ msg: 'Active journey not found.' });
    }

    // Record the check-in
    const newCheckIn = new CheckIn({
      journey: journey._id,
      user: req.user.id,
      location: req.body.location, // Optionally send current location with check-in
      status: 'CHECKED_IN',
    });
    await newCheckIn.save();

    // Update next check-in time for the journey
    journey.nextCheckInTime = new Date(Date.now() + journey.checkInIntervalMinutes * 60 * 1000);
    await journey.save();

    // TODO: Notify watchers via Socket.IO/SMS that user has checked in

    res.json(journey);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   POST /api/journey/:id/arrived
// @desc    User marks arrival, ending the journey
// @access  Private
router.post('/:id/arrived', auth, async (req, res) => {
  try {
    const journey = await Journey.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id, isActive: true },
      { $set: { arrivedSafely: true, isActive: false, endTime: Date.now() } },
      { new: true }
    );

    if (!journey) {
      return res.status(404).json({ msg: 'Active journey not found.' });
    }

    // TODO: Notify watchers via Socket.IO/SMS that user has arrived safely

    res.json(journey);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET /api/journey/active
// @desc    Get current active journey for the user
// @access  Private
router.get('/active', auth, async (req, res) => {
  try {
    const journey = await Journey.findOne({ user: req.user.id, isActive: true }).populate('watchers');
    res.json(journey);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;