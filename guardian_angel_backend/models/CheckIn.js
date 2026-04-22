const mongoose = require('mongoose');

const CheckInSchema = new mongoose.Schema({
  journey: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Journey',
    required: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  checkInTime: {
    type: Date,
    default: Date.now,
  },
  location: {
    lat: Number,
    lng: Number,
  },
  status: {
    type: String,
    enum: ['CHECKED_IN', 'MISSED', 'ALERTED'],
    default: 'CHECKED_IN',
  },
}, { timestamps: true });

module.exports = mongoose.model('CheckIn', CheckInSchema);