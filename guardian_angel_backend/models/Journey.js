const mongoose = require('mongoose');

const JourneySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  watchers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Contact', // Reference to Contact model
  }],
  startLocation: {
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
  },
  endLocation: {
    lat: Number,
    lng: Number,
  },
  startTime: {
    type: Date,
    default: Date.now,
  },
  endTime: {
    type: Date,
  },
  arrivedSafely: {
    type: Boolean,
    default: false,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  checkInIntervalMinutes: {
    type: Number,
    default: 15,
  },
  nextCheckInTime: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('Journey', JourneySchema);