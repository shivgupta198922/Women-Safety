const mongoose = require('mongoose');

const CheckInSessionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  expiresAt: { type: Date, required: true },
  responseStatus: { type: String, enum: ['safe', 'unsafe', 'pending'], default: 'pending' },
  location: {
    lat: Number,
    lng: Number
  },
  watchers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  autoSOS: { type: Boolean, default: false }
}, { timestamps: true });

CheckInSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('CheckInSession', CheckInSessionSchema);

