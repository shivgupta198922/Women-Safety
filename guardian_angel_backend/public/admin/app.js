// Admin Dashboard Real-time
const socket = io('http://localhost:5000');
let map = L.map('map').setView([20.5937, 78.9629], 5); // India center

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

let activeAlerts = [];
let sosMarkers = L.layerGroup().addTo(map);

// Stats
socket.on('sos-received', (data) => {
  updateAlert(data);
  addSOSMarker(data);
});

socket.on('location-update', (data) => {
  updateUserLocation(data);
});

function updateAlert(data) {
  const alertsDiv = document.getElementById('alerts');
  const alertDiv = document.createElement('div');
  alertDiv.className = 'alert';
  alertDiv.innerHTML = `
    <strong>${data.type.toUpperCase()}</strong><br>
    User: ${data.userId.substring(0,8)}...<br>
    Location: ${data.location.lat.toFixed(4)}, ${data.location.lng.toFixed(4)}<br>
    Time: ${new Date().toLocaleTimeString()}
  `;
  alertsDiv.insertBefore(alertDiv, alertsDiv.firstChild);
  
  document.getElementById('active-sos').textContent = activeAlerts.length;
  if (activeAlerts.length > 5) alertsDiv.removeChild(alertsDiv.lastChild);
}

function addSOSMarker(data) {
  const marker = L.marker([data.location.lat, data.location.lng]).addTo(sosMarkers)
    .bindPopup(`SOS - ${data.type}<br>User: ${data.userId.substring(0,8)}`);
  marker.setIcon(L.icon({
    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
    iconSize: [25, 41]
  }));
  activeAlerts.push(marker);
}

function updateUserLocation(data) {
  // Update user markers
}

socket.emit('join-room', 'admins');

// Fake stats
setInterval(() => {
  document.getElementById('total-users').textContent = Math.floor(Math.random()*1000)+500;
  document.getElementById('today-alerts').textContent = Math.floor(Math.random()*50)+10;
}, 5000);

