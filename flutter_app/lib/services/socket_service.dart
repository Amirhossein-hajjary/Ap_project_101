import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  static const String serverIp = '192.168.1.54';
  static const int serverPort = 5000;

  Socket? _socket;
  StreamSubscription? _subscription;
  int _requestIdCounter = 0;

  /// ذخیره درخواست‌های منتظر پاسخ با استفاده از شناسه یکتا
  final Map<String, Completer<Map<String, dynamic>>> _pendingResponses = {};

  Future<void> connect() async {
    if (_socket != null) return;

    try {
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
          try {
            final Map<String, dynamic> response = jsonDecode(line);
            // دریافت requestId از پاسخ سرور
            final String? requestId = response['requestId']?.toString();

            if (requestId != null && _pendingResponses.containsKey(requestId)) {
              final completer = _pendingResponses.remove(requestId);
              if (completer != null && !completer.isCompleted) {
                completer.complete(response);
              }
            } else if (_pendingResponses.isNotEmpty && requestId == null) {
              // در صورتی که سرور هنوز requestId را برنمی‌گرداند، به عنوان fallback از FIFO استفاده می‌کنیم
              // اما بهتر است سرور آپدیت شود
              final firstKey = _pendingResponses.keys.first;
              final completer = _pendingResponses.remove(firstKey);
              if (completer != null && !completer.isCompleted) {
                completer.complete(response);
              }
            }
          } catch (e) {
            debugPrint('Error parsing response: $e');
          }
        },
        onError: (error) {
          _failAllPending('connection failure: $error');
          _cleanup();
        },
        onDone: () {
          _failAllPending('lost connection');
          _cleanup();
        },
      );
    } catch (e) {
      _cleanup();
      rethrow;
    }
  }

  void _failAllPending(String message) {
    for (var completer in _pendingResponses.values) {
      if (!completer.isCompleted) completer.completeError(message);
    }
    _pendingResponses.clear();
  }

  void _cleanup() {
    _subscription?.cancel();
    _socket?.destroy();
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
      throw 'couldnt connect to server: $e';
    }

    // تولید شناسه یکتا برای این درخواست
    final String requestId = (_requestIdCounter++).toString();
    
    final Map<String, dynamic> requestData = {
      'requestId': requestId,
      'method': method,
      'username': username,
      'route': route,
      'payload': payload,
    };

    final completer = Completer<Map<String, dynamic>>();
    _pendingResponses[requestId] = completer;

    try {
      _socket!.write('${jsonEncode(requestData)}\n');
    } catch (e) {
      _pendingResponses.remove(requestId);
      throw 'unsuccessful request: $e';
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        _pendingResponses.remove(requestId);
        throw 'پاسخی از سرور دریافت نشد (Timeout) - ID: $requestId';
      },
    );
  }

  void disconnect() {
    _failAllPending('اتصال توسط کاربر بسته شد');
    _socket?.close();
    _cleanup();
  }
}
