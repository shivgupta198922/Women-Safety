const mongoose = require('mongoose');

const ConcernReportSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['stalking', 'harassment', 'unsafe_taxi', 'unsafe_location', 'suspicious'], required: true },
  description: { type: String, required: true },
  anonymous: { type: Boolean, default: false },
  location: {
    lat: Number,
    lng: Number
  },
  evidence: [{
    url: String,
    type: String, // image/video/audio
    timestamp: Date
  }],
  status: { type: String, enum: ['pending', 'reviewed', 'actioned', 'closed'], default: 'pending' },
  adminNotes: String
}, { timestamps: true });

module.exports = mongoose.model('ConcernReport', ConcernReportSchema);

