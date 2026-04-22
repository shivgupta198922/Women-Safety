const jwt = require('jsonwebtoken');
const User = require('../models/User');
const mongoose = require('mongoose');

const auth = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token'); // Assuming token is sent in 'x-auth-token' header
    if (!token) return res.status(401).json({ error: 'No token, authorization denied' });

    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({ error: 'Database unavailable. Please try again shortly.' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET); // decoded.user.id from auth/login
    const user = await User.findById(decoded.user.id);
    if (!user) return res.status(401).json({ error: 'Invalid token' });
    
    req.user = user; // Attach the full user object to the request
    next();
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token is not valid' });
    }

    console.error('Auth middleware error:', err.message);
    return res.status(500).json({ error: 'Authentication failed due to a server error' });
  }
};

module.exports = auth;
