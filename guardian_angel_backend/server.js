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

const adminRouter = express.Router();

const app = express();
const server = http.createServer(app);
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

mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Routes
app.get('/', (req, res) => res.send('Guardian Angel Backend Running'));

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

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something broke!' });
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
      // Fetch emergency contacts for the user
      const emergencyContacts = await Contact.find({ user: userId, isEmergency: true }).select('name phoneNumber email');

      // Emit SOS to the sender's own room for confirmation/status update
      io.to(userId).emit('sos-confirmed', { message: 'Your SOS has been sent.', data });

      // Emit SOS to each emergency contact's room
      for (const contact of emergencyContacts) {
        // Assuming contact.user is the ID of the user who is the emergency contact
        // This requires emergency contacts to also be Guardian Angel app users and logged in.
        // For external contacts (SMS/Email), that logic would be in the /api/sos/send route.
        io.to(contact.user.toString()).emit('receiveSOS', {
          senderId: userId,
          senderName: data.senderName, // Client should send sender's name
          message: `Emergency alert from ${data.senderName || 'a user'}!`,
          location,
          type,
        });
        console.log(`Emitted SOS to emergency contact ${contact.name} (room: ${contact.user})`);
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
