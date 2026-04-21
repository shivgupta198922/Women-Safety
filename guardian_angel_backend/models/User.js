const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profilePic: String,
  fcmToken: String,
  emergencyContacts: [{ type: String }], // phone numbers
  safetyCircles: [{ type: mongoose.Schema.Types.ObjectId, ref: 'SafetyCircle' }],
  isAdmin: { type: Boolean, default: false },
  settings: {
    theme: { type: String, default: 'system' },
    sosPreferences: {
      enableShake: { type: Boolean, default: true },
      enableVoice: { type: Boolean, default: true },
      countdownSeconds: { type: Number, default: 10 },
      autoRecord: { type: Boolean, default: true }
    },
    privacy: {
      locationShare: { type: Boolean, default: true },
      anonymousReports: { type: Boolean, default: false }
    },
    notifications: { type: Boolean, default: true },
    rakshakMode: { type: Boolean, default: false }
  },
  lastLocation: {
    lat: Number,
    lng: Number,
    timestamp: { type: Date, default: Date.now }
  },
  lastCheckin: Date
}, { timestamps: true });

module.exports = mongoose.model("User", UserSchema);

