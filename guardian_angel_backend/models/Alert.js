const mongoose = require('mongoose');

const AlertSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['SOS_PANIC', 'SHAKE_SOS', 'VOICE_SOS', 'CHECKIN_MISSED', 'RAISE_CONCERN'],
    required: true,
  },
  location: {
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
    timestamp: { type: Date, default: Date.now },
  },
  message: { type: String },
  audioRecordingUrl: { type: String }, // URL to audio recording (optional)
  videoRecordingUrl: { type: String }, // URL to video recording (optional)
  status: { type: String, enum: ['PENDING', 'SENT', 'RESOLVED'], default: 'PENDING' },
  notifiedContacts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Contact' }],
  // Add more fields as needed, e.g., evidence (images), notes
}, { timestamps: true });

module.exports = mongoose.model("Alert", AlertSchema);
