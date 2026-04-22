import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentAccountType;
  String? _currentUserName;

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
      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        _socket.emit('join-room', _currentUserId);
      }
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket.onError((data) => print('Socket Error: $data'));
    _socket.on('receiveSOS', (data) {
      print('Received SOS from server: $data');
      final senderName = (data is Map && data['senderName'] != null)
          ? data['senderName'].toString()
          : 'your safety network';
      final senderType = (data is Map && data['senderAccountType'] != null)
          ? data['senderAccountType'].toString()
          : '';
      final message = _buildSosMessage(senderName: senderName, senderType: senderType);

      AppUtils.showGlobalSosDialog(
        title: 'Emergency Alert',
        message: message,
      );
      AppUtils.showGlobalSnackBar('SOS alert from $senderName', isError: true);
    });
    _socket.on('receiveLocation', (data) => print('Received Location from server: $data'));
  }

  void connect({String? userId, String? accountType, String? userName}) {
    if (userId != null && userId.isNotEmpty) {
      _currentUserId = userId;
    }
    if (accountType != null && accountType.isNotEmpty) {
      _currentAccountType = accountType;
    }
    if (userName != null && userName.isNotEmpty) {
      _currentUserName = userName;
    }

    if (!_isConnected) {
      _socket.connect();
    } else if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      _socket.emit('join-room', _currentUserId);
    }
  }

  void disconnect() {
    _socket.disconnect();
    _currentUserId = null;
    _currentAccountType = null;
    _currentUserName = null;
  }

  String _buildSosMessage({
    required String senderName,
    required String senderType,
  }) {
    if (_currentAccountType == 'parent' && senderType == 'child') {
      return 'Your child $senderName is in danger and has sent an SOS. Please check immediately.';
    }

    if (_currentAccountType == 'child' && senderType == 'parent') {
      return 'Your parent $senderName has sent an SOS alert. Please respond immediately.';
    }

    if (_currentUserName != null && senderName.toLowerCase() == _currentUserName!.toLowerCase()) {
      return 'Your SOS alert has been triggered successfully.';
    }

    return '$senderName is in danger and has sent an SOS alert. Please check immediately.';
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
