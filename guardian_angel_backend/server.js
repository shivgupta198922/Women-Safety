require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const helmet = require('helmet'); // Import helmet
const { Server } = require('socket.io');
const { validationResult, check } = require('express-validator'); // Import express-validator

const authRouter = require('./routes/auth');
const contactsRouter = require('./routes/contacts');
const sosRouter = require('./routes/sos');
const locationRouter = require('./routes/location');
const Contact = require('./models/Contact'); // Import Contact model for SOS notifications
const Journey = require('./models/Journey'); // Import Journey model for live location watchers
const journeyRouter = require('./routes/journey'); // New import
const auth = require('./middleware/auth'); // Corrected import
const User = require('./models/User');

const adminRouter = express.Router();

const app = express();
const server = http.createServer(app);
let mongoConnectionError = null;
const io = new Server(server, {
  cors: {
    origin: '*', // TODO: Restrict this to your frontend domain(s) in production, e.g., 'https://yourfrontend.com'
    methods: ['GET', 'POST']
  }
});

app.use(cors({
  origin: '*', // TODO: Restrict this to your frontend domain(s) in production, e.g., 'https://yourfrontend.com'
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true,
}));
app.use(express.json());
app.use(helmet()); // Use Helmet for security headers

// Rate limiting to prevent brute-force attacks
const rateLimit = require('express-rate-limit');
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again after 15 minutes',
});
app.use('/api/', apiLimiter); // Apply to all API routes

async function reconcileUserIndexes() {
  try {
    const indexes = await User.collection.indexes();
    const hasLegacyPhoneIndex = indexes.some((index) => index.name === 'phone_1');

    if (hasLegacyPhoneIndex) {
      await User.collection.dropIndex('phone_1');
      console.log('Dropped legacy users.phone_1 index');
    }

    await User.syncIndexes();
  } catch (error) {
    console.error('Failed to reconcile user indexes:', error.message);
  }
}

function getMongoStatus() {
  const stateMap = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  return {
    readyState: mongoose.connection.readyState,
    status: stateMap[mongoose.connection.readyState] || 'unknown',
    error: mongoConnectionError,
  };
}

async function resolveSosRecipientIds(senderId) {
  const sender = await User.findById(senderId).select('email phoneNumber accountType securePairing fullName');
  if (!sender) {
    return [];
  }

  const recipientIds = new Set();

  const emergencyContacts = await Contact.find({ user: senderId, isEmergency: true }).select('phoneNumber email name');
  const contactPhones = emergencyContacts
    .map((contact) => contact.phoneNumber?.trim())
    .filter(Boolean);
  const contactEmails = emergencyContacts
    .map((contact) => contact.email?.trim()?.toLowerCase())
    .filter(Boolean);

  if (contactPhones.length > 0 || contactEmails.length > 0) {
    const matchedUsers = await User.find({
      $or: [
        ...(contactPhones.length > 0 ? [{ phoneNumber: { $in: contactPhones } }] : []),
        ...(contactEmails.length > 0 ? [{ email: { $in: contactEmails } }] : []),
      ],
    }).select('_id');

    matchedUsers.forEach((user) => {
      if (user._id.toString() !== senderId.toString()) {
        recipientIds.add(user._id.toString());
      }
    });
  }

  const senderPairing = sender.securePairing || {};
  const targetPairingCode = senderPairing.targetPairingCode?.trim();
  const ownPairingCode = senderPairing.pairingCode?.trim();

  if (sender.accountType === 'child' && targetPairingCode) {
    const parent = await User.findOne({
      accountType: { $in: ['parent', 'guardian'] },
      'securePairing.pairingCode': targetPairingCode,
    }).select('_id securePairing');

    if (parent && parent.securePairing?.accessPermissions?.notifications !== false) {
      recipientIds.add(parent._id.toString());
    }
  }

  if (['parent', 'guardian'].includes(sender.accountType) && ownPairingCode) {
    const children = await User.find({
      accountType: 'child',
      'securePairing.targetPairingCode': ownPairingCode,
    }).select('_id securePairing');

    children.forEach((child) => {
      if (child.securePairing?.accessPermissions?.notifications !== false) {
        recipientIds.add(child._id.toString());
      }
    });
  }

  return Array.from(recipientIds);
}

mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    console.log('MongoDB Connected');
    mongoConnectionError = null;
    await reconcileUserIndexes();
  })
  .catch(err => {
    mongoConnectionError = err.message;
    console.error('MongoDB connection error:', err);
  });

mongoose.connection.on('connected', () => {
  mongoConnectionError = null;
});

mongoose.connection.on('error', (err) => {
  mongoConnectionError = err.message;
});

mongoose.connection.on('disconnected', () => {
  if (!mongoConnectionError) {
    mongoConnectionError = 'MongoDB disconnected';
  }
});

// Routes
app.get('/', (req, res) => res.send('Guardian Angel Backend Running'));
app.get('/api/health', (req, res) => {
  const mongo = getMongoStatus();
  const statusCode = mongo.status === 'connected' ? 200 : 503;

  res.status(statusCode).json({
    ok: mongo.status === 'connected',
    service: 'guardian_angel_backend',
    time: new Date().toISOString(),
    mongo,
  });
});

app.use('/api/auth', authRouter);
app.use('/api/contacts', auth, contactsRouter); // Apply auth middleware
app.use('/api/sos', auth, sosRouter); // Apply auth middleware
app.use('/api/location', auth, locationRouter); // Apply auth middleware
app.use('/api/journey', auth, journeyRouter); // New route

// Placeholder routes for future features (can be created as separate files)
// app.use('/api/fakecall', auth, require('./routes/fakecall'));
// app.use('/api/rakshak', auth, require('./routes/rakshak'));
// app.use('/api/checkin', auth, require('./routes/checkin')); // Assuming checkin needs auth
// app.use('/api/nearby', require('./routes/nearby')); // Nearby might not need auth for public data, depending on implementation
// app.use('/api/admin', auth, adminRouter); // Admin routes should be protected

// Serve admin dashboard
app.use('/admin', express.static('public/admin'));

app.set('socketio', io);

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something broke!',
    mongo: getMongoStatus(),
  });
});

// Socket.IO for real-time communication
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // When a user logs in, they should join a room with their userId
  socket.on('join-room', (userId) => { // Client sends userId after successful login
    if (userId) {
      socket.join(userId);
      console.log(`User ${userId} joined room: ${userId}`);
    } else {
      console.warn('Attempted to join room with null userId');
    }
  });

  // Handle SOS alerts from the client
  socket.on('sendSOS', async (data) => {
    console.log('SOS received from client:', data);
    const { userId, type, location, message, audioRecordingUrl, videoRecordingUrl } = data;

    if (!userId) {
      console.error('sendSOS event received without userId.');
      return;
    }

    try {
      const sender = await User.findById(userId).select('accountType fullName');
      const recipientIds = await resolveSosRecipientIds(userId);

      // Emit SOS to the sender's own room for confirmation/status update
      io.to(userId).emit('sos-confirmed', { message: 'Your SOS has been sent.', data });

      // Emit SOS to each resolved app user room, including paired parent/child accounts.
      for (const recipientId of recipientIds) {
        io.to(recipientId).emit('receiveSOS', {
          senderId: userId,
          senderName: data.senderName || sender?.fullName, // Client should send sender's name
          senderAccountType: sender?.accountType,
          message: `Emergency alert from ${data.senderName || 'a user'}!`,
          location,
          type,
          audioRecordingUrl,
          videoRecordingUrl,
        });
        console.log(`Emitted SOS to recipient room: ${recipientId}`);
      }
    } catch (error) {
      console.error('Error processing sendSOS event:', error);
      io.to(userId).emit('sos-error', { message: 'Failed to send SOS.', error: error.message });
    }
  });

  // Handle live location updates from the client
  socket.on('updateLocation', async (data) => {
    console.log('Location update received from client:', data);
    const { userId, latitude, longitude, timestamp } = data;

    if (!userId) {
      console.error('updateLocation event received without userId.');
      return;
    }

    try {
      // Emit to the sender's own room for confirmation/status update
      io.to(userId).emit('location-update-confirmed', { message: 'Your location has been updated.', data });

      // Find active journey for this user to get watchers
      const activeJourney = await Journey.findOne({ user: userId, isActive: true }).populate('watchers');

      if (activeJourney && activeJourney.watchers.length > 0) {
        for (const watcherContact of activeJourney.watchers) {
          // Assuming watcherContact.user is the ID of the user who is the watcher
          io.to(watcherContact.user.toString()).emit('receiveLocation', {
            senderId: userId,
            senderName: data.senderName, // Client should send sender's name
            message: `Live location update from ${data.senderName || 'a user'}`,
            latitude,
            longitude,
            timestamp,
            journeyId: activeJourney._id,
          });
          console.log(`Emitted live location to watcher ${watcherContact.name} (room: ${watcherContact.user})`);
        }
      } else {
        // If no active journey or watchers, you might still want to emit to a general "admin" room
        // or a "safety-network" room if implemented.
        // For now, if no specific watchers, we just log.
        console.log(`No active journey watchers for user ${userId}. Location not broadcast to specific watchers.`);
      }
    } catch (error) {
      console.error('Error processing updateLocation event:', error);
      io.to(userId).emit('location-update-error', { message: 'Failed to update location.', error: error.message });
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
