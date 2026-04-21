require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const authRouter = require('./routes/auth');
const authMiddleware = require('./middleware/auth');
// Placeholder for other routes - will create
const contactsRouter = require('./routes/contacts');
const usersRouter = express.Router();
const sosRouter = express.Router();
const rakshakRouter = require('./routes/rakshak');
const fakecallRouter = require('./routes/fakecall');
const checkinRouter = require('./routes/checkin');
const locationRouter = express.Router();
const nearbyRouter = express.Router();
const adminRouter = express.Router();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log('MongoDB connection error:', err));

// Routes
app.get('/', (req, res) => res.send('Guardian Angel Backend Running'));

app.use('/api/auth', authRouter);
app.use('/api/users', authMiddleware, usersRouter);
app.use('/api/contacts', authMiddleware, contactsRouter);
app.use('/api/sos', authMiddleware, sosRouter);
app.use('/api/fakecall', authMiddleware, fakecallRouter);
app.use('/api/rakshak', authMiddleware, rakshakRouter);
app.use('/api/checkin', authMiddleware, checkinRouter);
app.use('/api/location', authMiddleware, locationRouter);
app.use('/api/nearby', nearbyRouter);
app.use('/api/admin', authMiddleware, adminRouter);

// Security middleware (optional deps - comment out if not installed)
 // app.use(require('helmet')());
 // const limiter = require('express-rate-limit');
 // app.use(limiter({
 //   windowMs: 15 * 60 * 1000,
 //   max: 100
 // }));


// Serve admin dashboard
app.use('/admin', express.static('public/admin'));

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something broke!' });
});

// Socket.IO for real-time enhanced
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join-room', (userId) => {
    socket.join(userId);
    socket.join('safety-network-' + userId);
    console.log(`User ${userId} joined rooms`);
  });

  socket.on('sos-alert', async (data) => {
    const { userId, location, type, message, evidenceUrl } = data;
    // Save alert, notify contacts/admins/groups
    io.to('admins').emit('sos-received', data);
    io.to(userId).emit('sos-confirmed', data);
    // TODO: FCM push to emergencyContacts/safetyCircle
    // TODO: SMS fallback via nodemailer/Twilio
    console.log('SOS Alert:', data);
  });

  socket.on('live-location', async (data) => {
    const { userId, location, sessionId } = data;
    io.to('admins').emit('location-update', data);
    io.to('safety-network-' + userId).emit('location-share', data);
    // Update user.lastLocation
  });

  socket.on('checkin-reminder', (data) => {
    io.to(data.userId).emit('checkin-alert', data);
  });

  socket.on('group-sos', (data) => {
    const { circleId, ...alertData } = data;
    io.to('safety-network-' + circleId).emit('group-sos-alert', alertData);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
