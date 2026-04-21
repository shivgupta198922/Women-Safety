const mongoose = require('mongoose');

const SupportRequestSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['legal', 'counseling', 'ngo', 'helpline'], required: true },
  description: { type: String, required: true },
  preferredContact: { type: String }, // phone/email
  status: { type: String, enum: ['pending', 'assigned', 'completed'], default: 'pending' },
  assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // council admin
  chatHistory: [{
    message: String,
    sender: String,
    timestamp: { type: Date, default: Date.now }
  }]
}, { timestamps: true });

module.exports = mongoose.model('SupportRequest', SupportRequestSchema);

