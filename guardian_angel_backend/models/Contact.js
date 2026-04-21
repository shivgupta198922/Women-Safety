const mongoose = require('mongoose');

const ContactSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  relationship: String, // e.g. 'Mother', 'Friend'
  isPrimary: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model("Contact", ContactSchema);
