import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();


  static const String serverIp = '192.168.1.54';
  static const int serverPort = 5000;

  Socket? _socket;
  StreamSubscription? _subscription;


  final List<Completer<Map<String, dynamic>>> _pendingResponses = [];

  Future<void> connect() async {
    if (_socket != null) return;

    _socket = await Socket.connect(
      serverIp,
      serverPort,
      timeout: const Duration(seconds: 5),
    );

    _subscription = _socket!
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
        if (_pendingResponses.isNotEmpty) {
          final completer = _pendingResponses.removeAt(0);
          try {
            final Map<String, dynamic> response = jsonDecode(line);
            if (!completer.isCompleted) completer.complete(response);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError('unvalid response');
            }
          }
        }
      },
      onError: (error) {
        _failAllPending('connection failure');
        _cleanup();
      },
      onDone: () {
        _failAllPending('lost connection');
        _cleanup();
      },
    );
  }

  void _failAllPending(String message) {
    for (final c in _pendingResponses) {
      if (!c.isCompleted) c.completeError(message);
    }
    _pendingResponses.clear();
  }

  void _cleanup() {
    _subscription?.cancel();
    _socket = null;
    _subscription = null;
  }

  Future<Map<String, dynamic>> sendRequest({
    required String method,
    required String route,
    String username = '',
    required Map<String, dynamic> payload,
  }) async {
    try {
      await connect();
    } catch (e) {
      throw 'couldnt connect';
    }

    final Map<String, dynamic> requestData = {
      'method': method,
      'username': username,
      'route': route,
      'payload': payload,
    };

    final completer = Completer<Map<String, dynamic>>();
    _pendingResponses.add(completer);

    try {
      _socket!.write('${jsonEncode(requestData)}\n');
    } catch (e) {
      _pendingResponses.remove(completer);
      throw 'unssucceful request';
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _pendingResponses.remove(completer);
        throw 'پاسخی از سرور دریافت نشد (Timeout)';
      },
    );
  }

  void disconnect() {
    _failAllPending('اتصال توسط کاربر بسته شد');
    _socket?.close();
    _cleanup();
  }
}