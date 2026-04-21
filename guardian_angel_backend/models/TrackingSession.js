const mongoose = require('mongoose');

const TrackingSessionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  watchers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  startLocation: {
    lat: Number,
    lng: Number
  },
  currentLocation: {
    lat: Number,
    lng: Number
  },
  destination: {
    lat: Number,
    lng: Number,
    eta: Number
  },
  route: [String],
  safeArrival: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
  geofenceAlerts: [String]
}, { timestamps: true });

module.exports = mongoose.model('TrackingSession', TrackingSessionSchema);

