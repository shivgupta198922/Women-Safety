const mongoose = require('mongoose');

const AlertSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['sos_button', 'shake', 'voice', 'fake_call'], required: true },
  location: {
    lat: Number,
    lng: Number
  },
  status: { type: String, enum: ['pending', 'sent', 'acknowledged'], default: 'pending' },
  notifiedContacts: [String],
  message: String,
  recordingUrl: String // for secret recording
}, { timestamps: true });

module.exports = mongoose.model("Alert", AlertSchema);
