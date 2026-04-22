import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;
  bool _isConnected = false;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _socket = IO.io(AppConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((_) {
      print('Socket connected');
      _isConnected = true;
      // Optionally join a user-specific room here if userId is available
      // For now, we'll assume the backend handles general broadcasts or specific room joins
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket.onError((data) => print('Socket Error: $data'));
    _socket.on('receiveSOS', (data) => print('Received SOS from server: $data'));
    _socket.on('receiveLocation', (data) => print('Received Location from server: $data'));
  }

  void connect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  void disconnect() {
    _socket.disconnect();
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
    } else {
      print('Socket not connected, cannot emit event: $event');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _socket.off(event, handler);
    } else {
      _socket.off(event);
    }
  }
}
