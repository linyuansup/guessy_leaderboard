import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scribble/scribble.dart';
import 'package:leaderboard/generated/proto/leaderboard.pb.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WebSocketProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

class WebSocketProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  String _host = '';
  String _port = '';
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final StreamController<dynamic> _messageController =
      StreamController<dynamic>.broadcast();
  StreamSubscription? _subscription;

  bool get isConnected => _channel != null;
  String get host => _host;
  String get port => _port;
  Stream<dynamic> get messageStream => _messageController.stream;

  Future<void> connect(String host, String port) async {
    _host = host;
    _port = port;
    await _createConnection();
    notifyListeners();
  }

  Future<void> _createConnection() async {
    final wsUrl = 'ws://$_host:$_port/ws/leaderboard';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    await _channel!.ready;
    _reconnectAttempts = 0;
    _isReconnecting = false;

    _subscription?.cancel();
    _subscription = _channel!.stream.listen(
      (message) {
        _messageController.add(message);
      },
      onError: (error) {
        _handleDisconnect();
      },
      onDone: () {
        _handleDisconnect();
      },
    );
  }

  void send(dynamic message) {
    _channel?.sink.add(message);
  }

  void _handleDisconnect() {
    if (!isConnected) return;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _isReconnecting = true;
      notifyListeners();
      _reconnectAttempts++;
      Future.delayed(_reconnectDelay, () {
        reconnect();
      });
    } else {
      _isReconnecting = false;
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    if (_isReconnecting && _reconnectAttempts >= _maxReconnectAttempts) return;

    _isReconnecting = true;

    while (_reconnectAttempts < _maxReconnectAttempts) {
      try {
        await _createConnection();
        _isReconnecting = false;
        notifyListeners();
        return;
      } catch (e) {
        _reconnectAttempts++;
        if (_reconnectAttempts < _maxReconnectAttempts) {
          await Future.delayed(_reconnectDelay);
        }
      }
    }

    _isReconnecting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _messageController.close();
    _channel?.sink.close();
    super.dispose();
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
      final provider = Provider.of<WebSocketProvider>(context, listen: false);
      await provider.connect(host, port);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
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
      appBar: AppBar(title: const Text('Connect to Server'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings_ethernet, size: 80, color: Colors.blue),
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    provider.messageStream.listen(
      (message) {
        if (!mounted) return;

        if (message is Uint8List && message.isNotEmpty) {
          if (message[0] == 7 && message.length > 1) {
            try {
              final question = Question.fromBuffer(message.sublist(1));
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GamePage(question: question),
                ),
              );
            } catch (e) {
              // Failed to parse, ignore
            }
          }
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

  void _handleDisconnect() {
    if (!mounted) return;
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    provider.reconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Waiting for start...',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final Question question;

  const GamePage({super.key, required this.question});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _CommentItem {
  final String player;
  final String answer;
  final bool isCorrect;

  _CommentItem({
    required this.player,
    required this.answer,
    required this.isCorrect,
  });
}

class _GamePageState extends State<GamePage> {
  late final ScribbleNotifier _scribbleNotifier;
  double _dividerPosition = 0.7;
  final List<_CommentItem> _comments = [];
  final ScrollController _commentsScrollController = ScrollController();
  late Timer _timer;
  int _remainingSeconds = 90; // 1.5 minutes

  @override
  void initState() {
    super.initState();
    _scribbleNotifier = ScribbleNotifier();
    _startCountdown();
    _listenToMessages();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer.cancel();
          _stopGame();
        }
      });
    });
  }

  Future<void> _stopGame() async {
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    final url = Uri.parse('http://${provider.host}:${provider.port}/api/stop');
    try {
      await http.post(url);
    } catch (e) {
      // Failed to call API, ignore
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _listenToMessages() {
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    provider.messageStream.listen(
      (message) {
        if (message is Uint8List && message.isNotEmpty) {
          if (message[0] == 1 && message.length > 1) {
            try {
              final update = LeaderboardUpdated.fromBuffer(message.sublist(1));
              final sketchJson =
                  json.decode(update.leaderboard) as Map<String, dynamic>;
              final sketch = Sketch.fromJson(sketchJson);
              _scribbleNotifier.setSketch(
                sketch: sketch,
                addToUndoHistory: false,
              );
            } catch (e) {
              // Failed to parse, ignore
            }
          } else if (message[0] == 6 && message.length > 1) {
            try {
              final answer = AddAnswer.fromBuffer(message.sublist(1));
              final isCorrect =
                  answer.answer.trim().toLowerCase() ==
                  widget.question.content.trim().toLowerCase();
              setState(() {
                _comments.add(
                  _CommentItem(
                    player: answer.player,
                    answer: answer.answer,
                    isCorrect: isCorrect,
                  ),
                );
              });
              // Scroll to bottom after adding new comment
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _commentsScrollController.animateTo(
                  _commentsScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
            } catch (e) {
              // Failed to parse, ignore
            }
          }
        }
      },
      onError: (error) {
        provider.reconnect();
      },
      onDone: () {
        provider.reconnect();
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _commentsScrollController.dispose();
    _scribbleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          const dividerWidth = 8.0;
          final canvasWidth = (totalWidth - dividerWidth) * _dividerPosition;
          final commentsWidth =
              (totalWidth - dividerWidth) * (1 - _dividerPosition);

          return Column(
            children: [
              Container(
                width: constraints.maxWidth,
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: canvasWidth,
                      height: constraints.maxHeight - 64,
                      child: IgnorePointer(
                        child: Scribble(notifier: _scribbleNotifier),
                      ),
                    ),
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _dividerPosition += details.delta.dx / totalWidth;
                          _dividerPosition = _dividerPosition.clamp(0.2, 0.8);
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeColumn,
                        child: Container(
                          width: dividerWidth,
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: commentsWidth,
                      height: constraints.maxHeight - 64,
                      child: _comments.isEmpty
                          ? const Center(
                              child: Text(
                                'No comments yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: _commentsScrollController,
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    comment.isCorrect
                                        ? '[${comment.player}] 回答正确'
                                        : '[${comment.player}]: ${comment.answer}',
                                    style: TextStyle(
                                      color: comment.isCorrect
                                          ? Colors.green
                                          : Colors.black,
                                      fontWeight: comment.isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
