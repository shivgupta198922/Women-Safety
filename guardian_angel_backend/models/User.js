const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  fullName: { type: String, required: true }, // Changed from 'name' to 'fullName' for consistency
  email: { type: String, required: true, unique: true, trim: true, lowercase: true },
  phoneNumber: { type: String, required: true, unique: true, trim: true }, // Changed from 'phone' to 'phoneNumber'
  password: { type: String, required: true },
  accountType: {
    type: String,
    enum: ['individual', 'parent', 'child', 'hospital', 'police', 'council', 'guardian'],
    default: 'individual'
  },
  organizationName: String,
  departmentName: String,
  profilePic: String,
  fcmToken: String,
  // emergencyContacts: [{ type: String }], // This will now be managed via a separate Contact model
  safetyCircles: [{ type: mongoose.Schema.Types.ObjectId, ref: 'SafetyCircle' }], // Future feature
  isAdmin: { type: Boolean, default: false },
  settings: {
    theme: { type: String, default: 'system' },
    sosPreferences: {
      enableShake: { type: Boolean, default: true },
      enableVoice: { type: Boolean, default: true },
      countdownSeconds: { type: Number, default: 5 }, // Default countdown for SOS
      autoRecordAudio: { type: Boolean, default: true }, // Auto-record audio on SOS
      autoRecordVideo: { type: Boolean, default: false }, // Auto-record video on SOS
      sendSms: { type: Boolean, default: true },
      sendEmail: { type: Boolean, default: true },
      sendWhatsapp: { type: Boolean, default: false },
      sirenOnSos: { type: Boolean, default: true },
      callPolice: { type: Boolean, default: false },
      enableAIDetection: { type: Boolean, default: false }, // New AI setting
      autoAlertAIDetection: { type: Boolean, default: false }, // New AI setting
    }, // End sosPreferences
    defaultCheckInIntervalMinutes: { type: Number, default: 15 }, // New setting
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
    timestamp: { type: Date }
  },
  securePairing: {
    pairingCode: String,
    targetPairingCode: String,
    pairingStatus: {
      type: String,
      enum: ['unpaired', 'pending', 'linked'],
      default: 'unpaired'
    },
    devicePublicKey: String,
    accessPermissions: {
      notifications: { type: Boolean, default: true },
      liveLocation: { type: Boolean, default: true },
      camera: { type: Boolean, default: false },
      microphone: { type: Boolean, default: false }
    }
  },
  lastCheckin: Date
}, { timestamps: true });

module.exports = mongoose.model("User", UserSchema);
