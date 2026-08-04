import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  final StreamController<Map<String, dynamic>> _responseController =
  StreamController<Map<String, dynamic>>.broadcast();

  static const String serverIp = '192.168.1.54';
  static const int serverPort = 5000;

  Future<void> connect() async {
    if (_socket != null) return;

    _socket = await Socket.connect(serverIp, serverPort,
        timeout: const Duration(seconds: 5));

    _socket!
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
        final Map<String, dynamic> response = jsonDecode(line);
        _responseController.add(response);
      },
      onError: (error) {
        print('خطای سوکت: $error');
      },
      onDone: () {
        _socket = null;
      },
    );
  }

  Future<Map<String, dynamic>> sendRequest({
    required String method,
    required String route,
    String username = '',
    required Map<String, dynamic> payload,
  }) async {
    await connect();

    final Map<String, dynamic> requestData = {
      'method': method,
      'username': username,
      'route': route,
      'payload': payload,
    };

    final String jsonString = jsonEncode(requestData);

    final Future<Map<String, dynamic>> responseFuture =
        _responseController.stream.first;

    _socket!.write('$jsonString\n');

    return responseFuture.timeout(const Duration(seconds: 10));
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}

