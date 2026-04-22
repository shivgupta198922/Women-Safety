const mongoose = require('mongoose');

const ContactSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Changed from userId to user
  name: { type: String, required: true },
  phoneNumber: { type: String, required: true }, // Changed from phone to phoneNumber
  relationship: String, // e.g. 'Mother', 'Friend'
  email: String, // Added email for contact
  isEmergency: { type: Boolean, default: true } // Renamed from isPrimary to isEmergency
}, { timestamps: true });

module.exports = mongoose.model("Contact", ContactSchema);
