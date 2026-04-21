const express = require('express');
const router = express.Router();
const axios = require('axios'); // Add to package.json if needed

// Google Places API proxy for police/hospitals (user sends lat,lng,radius)
router.get('/police', async (req, res) => {
  try {
    const { lat, lng, radius = 5000 } = req.query;
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=police&key=${process.env.GOOGLE_PLACES_API_KEY}`;
    const response = await axios.get(url);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: 'Nearby search failed' });
  }
});

router.get('/hospital', async (req, res) => {
  try {
    const { lat, lng, radius = 5000 } = req.query;
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=hospital&key=${process.env.GOOGLE_PLACES_API_KEY}`;
    const response = await axios.get(url);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: 'Nearby search failed' });
  }
});

module.exports = router;
