import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  static void connect(String userId) {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) => print('Socket connected'));
    socket!.onDisconnect((_) => print('Socket disconnected'));

    socket!.emit('join-room', userId);

    socket!.on('sos-received', (data) => print('SOS Alert: $data'));
    socket!.on('location-update', (data) => print('Location update: $data'));
  }

  static void sosAlert(Map<String, dynamic> data) {
    socket?.emit('sos-alert', data);
  }

  static void liveLocation(Map<String, dynamic> data) {
    socket?.emit('live-location', data);
  }

  static void disconnect() {
    socket?.disconnect();
  }
}
