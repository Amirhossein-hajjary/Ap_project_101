import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _result = 'still not working';
  bool _loading = false;

  Future<void> _testPing() async {
    setState(() {
      _loading = true;
      _result = 'sending';
    });

    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/ping',
        payload: {},
      );
      setState(() {
        _result = 'server respone: $response';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'warning: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('test server')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testPing,
              child: const Text('Ping'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_result, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}