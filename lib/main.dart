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
  Timer? _timer;
  int _remainingSeconds = 90; // 1.5 minutes

  // Game configuration
  int _displayTopCount = 10;
  int _stopNumber = 0; // Number of correct answers to stop the game
  int _correctCount = 0; // Count of correct answers
  bool _gameEnded = false; // Flag to prevent multiple stops
  bool _stopRequestSent = false;
  bool _isGameStopped = false;
  final List<ScoreItem> _leaderboard = [];

  // Hint system
  List<String> _hintsList =
      []; // All hints including character count and content
  List<int> _hintDisplayTimes =
      []; // Times (in seconds) when each hint should be displayed
  int _currentHintIndex = 0; // Index of the next hint to display

  @override
  void initState() {
    super.initState();
    _scribbleNotifier = ScribbleNotifier();
    _loadGameConfig();
    _listenToMessages();
  }

  Future<void> _loadGameConfig() async {
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    final url = Uri.parse(
      'http://${provider.host}:${provider.port}/api/config?action=get',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final config = json.decode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _displayTopCount = config['displayTopCount'] as int? ?? 10;
          _remainingSeconds = config['duration'] as int? ?? 90;
          _stopNumber = config['stopNumber'] as int? ?? 0;
        });
        _initializeHints();
        _startCountdown();
      } else {
        if (!mounted) return;
        setState(() {
          _displayTopCount = 10;
          _remainingSeconds = 90;
          _stopNumber = 0;
        });
        _initializeHints();
        _startCountdown();
      }
    } catch (e) {
      // Failed to load config, use defaults
      if (!mounted) return;
      setState(() {
        _displayTopCount = 10;
        _remainingSeconds = 90;
        _stopNumber = 0;
      });
      _initializeHints();
      _startCountdown();
    }
  }

  void _initializeHints() {
    // Build hints list: character count + user hints + first character
    // Order: 1. char_count, 2-n. user hints, n+1. first_char (always last)
    _hintsList = [];
    _hintsList.add('char_count'); // First hint: character count (underscores)
    _hintsList.addAll(widget.question.hints); // User-provided hints
    _hintsList.add('first_char'); // Last hint: first character

    final totalHints = _hintsList.length;

    // Calculate hint display times (evenly distributed)
    // Formula: displayTime = totalSeconds - (i + 1) * (totalSeconds / (totalHints + 1))
    // This leaves space at both start and end
    _hintDisplayTimes = [];
    final interval = _remainingSeconds / (totalHints + 1);
    for (int i = 0; i < totalHints; i++) {
      final timeRemaining = (_remainingSeconds - (i + 1) * interval).toInt();
      _hintDisplayTimes.add(timeRemaining);
    }

    _currentHintIndex = 0;
  }

  void _startCountdown() {
    if (_gameEnded || _isGameStopped) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;

        // Check if any new hints should be displayed
        _checkAndDisplayHints();

        if (_remainingSeconds <= 0) {
          // Final check to ensure last hint is displayed
          _checkAndDisplayHints();
          Future.delayed(const Duration(seconds: 0), () async {
            if (!_gameEnded) {
              _gameEnded = true;
              await _stopGame();
            }
            _timer?.cancel();
          });
        }
      });
    });
  }

  void _checkAndDisplayHints() {
    while (_currentHintIndex < _hintsList.length &&
        _remainingSeconds <= _hintDisplayTimes[_currentHintIndex]) {
      final hint = _hintsList[_currentHintIndex];

      if (hint == 'char_count') {
        // First hint: character count (displayed as underscores in top bar)
        // This is handled in the UI, no action needed
      } else if (hint == 'first_char') {
        // Last hint: first character (displayed in top bar replacing first underscore)
        // This is handled in the UI, no action needed
      } else {
        // User hints: display in comments area
        setState(() {
          _comments.add(
            _CommentItem(player: '提示', answer: hint, isCorrect: false),
          );
        });
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _commentsScrollController.animateTo(
            _commentsScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }

      _currentHintIndex++;
    }
  }

  Future<void> _stopGame() async {
    if (_stopRequestSent) return;
    _stopRequestSent = true;
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    final url = Uri.parse('http://${provider.host}:${provider.port}/api/stop');
    try {
      await http.get(url);
    } catch (e) {
      // Failed to call API, ignore
    }
  }

  void _handleGameStopped(GameStopped stopped) {
    if (_isGameStopped) return;

    final topScores = stopped.scores.take(_displayTopCount).toList();
    setState(() {
      _isGameStopped = true;
      _gameEnded = true;
      _currentHintIndex = _hintsList.length;
      _leaderboard
        ..clear()
        ..addAll(topScores);
    });

    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Build the hint display for the top bar (underscores and first character)
  Widget _buildHintDisplay() {
    if (_isGameStopped) {
      return Text(
        widget.question.content,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
    }

    final answer = widget.question.content;

    // Don't show any hint until the first hint (char_count) is displayed
    if (_currentHintIndex == 0) {
      return const SizedBox.shrink(); // Show nothing initially
    }

    // Check if the 'first_char' hint has been displayed
    final showFirstChar =
        _hintsList.isNotEmpty &&
        _hintsList.last == 'first_char' &&
        _currentHintIndex > _hintsList.length - 1;

    // Build the hint text
    String hintText = '';
    for (int i = 0; i < answer.length; i++) {
      // Show first character if the last hint (first_char) has been displayed
      if (showFirstChar && i == 0) {
        hintText += answer[0];
      } else {
        // Display underscore for other characters
        hintText += '_';
      }
    }

    return Text(
      hintText,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        fontFamily: 'Monospace',
      ),
    );
  }

  void _listenToMessages() {
    final provider = Provider.of<WebSocketProvider>(context, listen: false);
    provider.messageStream.listen(
      (message) {
        if (message is Uint8List && message.isNotEmpty) {
          if (message[0] == 7 && message.length > 1) {
            try {
              final question = Question.fromBuffer(message.sublist(1));
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GamePage(question: question),
                ),
              );
            } catch (e) {
              // Failed to parse, ignore
            }
            return; // handled
          }
          if (message[0] == 3) {
            try {
              if (message.length <= 1) {
                _handleGameStopped(GameStopped(scores: []));
                return;
              }
              final stopped = GameStopped.fromBuffer(message.sublist(1));
              _handleGameStopped(stopped);
            } catch (e) {
              // Failed to parse, ignore
            }
          } else if (message[0] == 1 && message.length > 1) {
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
                // Increment correct count if answer is correct
                if (isCorrect) {
                  _correctCount++;
                }
              });
              // Scroll to bottom after adding new comment
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _commentsScrollController.animateTo(
                  _commentsScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });

              // Check if we've reached the stop number
              if (_stopNumber > 0 &&
                  _correctCount >= _stopNumber &&
                  !_gameEnded) {
                _gameEnded = true;
                Future.delayed(const Duration(seconds: 0), () async {
                  await _stopGame();
                  _timer?.cancel();
                });
              }
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
    _timer?.cancel();
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Center(child: _buildHintDisplay())),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                      child: _isGameStopped
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '正确答案',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.question.content,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_leaderboard.isEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          '无人答对',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _leaderboard.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No leaderboard data',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: _leaderboard.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final item = _leaderboard[index];
                                            return ListTile(
                                              leading: CircleAvatar(
                                                child: Text('${index + 1}'),
                                              ),
                                              title: Text(item.player),
                                              trailing: Text(
                                                '${item.score}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            )
                          : _comments.isEmpty
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
                                final isHint = comment.player == '提示';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: isHint
                                      ? Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.yellow.shade700,
                                            ),
                                          ),
                                          child: Text(
                                            '[${comment.player}] ${comment.answer}',
                                            style: TextStyle(
                                              color: Colors.yellow.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Text(
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
