const mongoose = require('mongoose');

const MediaEvidenceSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  alertId: { type: mongoose.Schema.Types.ObjectId, ref: 'Alert' },
  url: { type: String, required: true },
  type: { type: String, enum: ['audio', 'video', 'image'], required: true },
  duration: Number, // seconds for audio/video
  thumbnail: String,
  metadata: mongoose.Schema.Types.Mixed // GPS, timestamp, etc.
}, { timestamps: true });

module.exports = mongoose.model('MediaEvidence', MediaEvidenceSchema);

