import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaderboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ConnectPage(),
    );
  }
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _hostController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '5198');
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final host = _hostController.text.trim();
    final port = _portController.text.trim();

    if (host.isEmpty || port.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both host and port';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final wsUrl = 'ws://$host:$port/ws/leaderboard';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection to establish
      await channel.ready;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(host: host, port: port, channel: channel),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'Connection failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Server'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.settings_ethernet,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Server Address',
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              enabled: !_isConnecting,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: 'e.g., 8080',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dialpad),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isConnecting,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConnecting ? null : _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String host;
  final String port;
  final WebSocketChannel? initialChannel;

  const HomePage({
    super.key,
    required this.host,
    required this.port,
    WebSocketChannel? channel,
  }) : initialChannel = channel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebSocketChannel _channel;
  String _connectionStatus = 'Connected';
  int? _currentScore;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _channel = widget.initialChannel ?? WebSocketChannel.connect(
      Uri.parse('ws://${widget.host}:${widget.port}/ws/leaderboard'),
    );
    _connectionStatus = 'Connected to ${widget.host}:${widget.port}';
    _listenToMessages();
  }

  void _listenToMessages() {
    _channel.stream.listen(
      (message) {
        if (mounted) {
          setState(() {
            _connectionStatus = 'Connected to ${widget.host}:${widget.port}';
            _isReconnecting = false;
            _reconnectAttempts = 0;
            if (message is String) {
              final trimmed = message.trim();
              final number = int.tryParse(trimmed);
              if (number != null) {
                _currentScore = number;
              }
            } else if (message is num) {
              _currentScore = message.toInt();
            }
          });
        }
      },
      onError: (error) {
        _handleDisconnect();
      },
      onDone: () {
        _handleDisconnect();
      },
    );
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isNotEmpty) {
      _channel.sink.add(answer);
      _answerController.clear();
    }
  }

  void _handleDisconnect() {
    if (!mounted) return;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      setState(() {
        _connectionStatus = 'Reconnecting... (${_reconnectAttempts + 1}/$_maxReconnectAttempts)';
        _isReconnecting = true;
      });
      _reconnectAttempts++;
      _scheduleReconnect();
    } else {
      setState(() {
        _connectionStatus = 'Connection lost. Please restart.';
        _isReconnecting = false;
      });
    }
  }

  void _scheduleReconnect() {
    Future.delayed(_reconnectDelay, () {
      if (!mounted || !_isReconnecting) return;
      _attemptReconnect();
    });
  }

  Future<void> _attemptReconnect() async {
    if (!mounted) return;

    try {
      final wsUrl = 'ws://${widget.host}:${widget.port}/ws/leaderboard';
      final newChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await newChannel.ready;

      if (!mounted) {
        newChannel.sink.close();
        return;
      }

      // Close old channel and replace with new one
      _channel.sink.close();
      _channel = newChannel;

      setState(() {
        _connectionStatus = 'Connected to ${widget.host}:${widget.port}';
        _isReconnecting = false;
        _reconnectAttempts = 0;
      });

      _listenToMessages();
    } catch (e) {
      if (mounted && _reconnectAttempts < _maxReconnectAttempts) {
        _handleDisconnect();
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: _connectionStatus.contains('Connected') && !_connectionStatus.contains('Disconnected')
                ? Colors.green.shade100
                : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  _connectionStatus.contains('Connected') && !_connectionStatus.contains('Disconnected')
                      ? Icons.check_circle
                      : Icons.error,
                  color: _connectionStatus.contains('Connected') && !_connectionStatus.contains('Disconnected')
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _connectionStatus,
                    style: TextStyle(
                      color: _connectionStatus.contains('Connected') && !_connectionStatus.contains('Disconnected')
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Current Score',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentScore?.toString() ?? '--',
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            decoration: const InputDecoration(
                              labelText: 'Answer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
