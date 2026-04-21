const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: String,
  body: String,
  type: { type: String, enum: ['sos', 'checkin', 'tracking', 'concern'], required: true },
  data: mongoose.Schema.Types.Mixed,
  read: { type: Boolean, default: false },
  fcmToken: String
}, { timestamps: true });

module.exports = mongoose.model('Notification', NotificationSchema);

