import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:signalr_core/signalr_core.dart';

typedef OnNewMessageCallback = void Function(ChatMessage message);
typedef OnUpdateUnreadMessages = void Function(int? unreadMessages);

class ChatConnection {
  final UserManager userManager;
  final String host;
  final int port;

  HubConnection? _connection;

  ChatConnection(this.userManager, {required this.host, required this.port});

  List<OnNewMessageCallback> _onMessageHandlers = List.empty(growable: true);
  List<OnUpdateUnreadMessages> _unreadMessagesHandlers =
      List.empty(growable: true);

  Map<int, bool> _onlineUsers = new Map();

  bool isUserOnline(int userId) {
    return _onlineUsers[userId] ?? false;
  }

  connectToChat(int chatId) async {
    print('try connect to chat: $chatId');

    await checkConnection();

    if (_connection != null) {
      await _connection!.send(methodName: "ConnectToChat", args: [chatId]);
    }
  }

  listenMessages(OnNewMessageCallback onMessage) async {
    print('listent messages');

    await checkConnection();

    print('listen messages()');

    _onMessageHandlers.add(onMessage);
  }

  disableMessageListening(OnNewMessageCallback callback) async {
    await checkConnection();

    print('result on message handlers len: ${_onMessageHandlers.length}');

    _onMessageHandlers.remove(callback);

    print(
        'result on message handlers len after remove callback: ${_onMessageHandlers.length}');
  }

  listenOnUpdateUnreadMessages(
      OnUpdateUnreadMessages onUpdateUnreadMessages) async {
    print('listenOnUpdateUnreadMessages');

    await checkConnection();

    _unreadMessagesHandlers.add(onUpdateUnreadMessages);
  }

  disableOnUpdateUnreadMessages(OnUpdateUnreadMessages callback) async {
    await checkConnection();

    _unreadMessagesHandlers.remove(callback);
  }

  sendMessage(int chatId, String message) async {
    await checkConnection();

    if (_connection?.state == HubConnectionState.connected) {
      await _connection!.send(methodName: "Send", args: [chatId, message]);
    }
  }

  checkConnection() async {
    try {
      if (_connection == null) {
        _connection = _connection = HubConnectionBuilder()
            .withAutomaticReconnect()
            .withUrl(
                "http://$host:$port/chat",
                HttpConnectionOptions(
                    accessTokenFactory: () => userManager.getAccessToken()))
            .build();

        _connection?.on("Connect", (arguments) {
          print("Connected: $arguments");
        });
        _connection?.onclose((exception) {
          print("Chat connections loss: $exception");
        });

        _connection!.on(_EventTypes.OnMessage, _onMessage);
        _connection?.on(_EventTypes.OnUnreadMessages, _onUnreadMessages);

        _connection?.on("UserConnection", _onUserConnectionChanged);

        await _connection?.start();
      }
    } catch (ex, trace) {
      print(ex.toString());
      print(trace);
    }
  }

  disconnect() async {
    _onMessageHandlers.clear();
    _unreadMessagesHandlers.clear();
    _onlineUsers.clear();

    _connection?.stop();
    _connection = null;
  }

  void _onMessage(List<dynamic>? arguments) {
    print('Event: ${_EventTypes.OnMessage}: ' + arguments.toString());

    final json = arguments![0]["value"];

    final msg = ChatMessage.fromJson(json);

    print('onMessageHandlers len: ${_onMessageHandlers.length}');

    _onMessageHandlers.forEach((element) {
      element.call(msg);
    });
  }

  _onUnreadMessages(List<dynamic>? arguments) async {
    print('Event: ${_EventTypes.OnUnreadMessages}: ' + arguments.toString());

    final unreadMessages = arguments?[0];

    _unreadMessagesHandlers.forEach((element) {
      element.call(unreadMessages);
    });
  }

  void _onUserConnectionChanged(List<dynamic>? arguments) {
    if (arguments != null) {
      final int userId = arguments[0];
      final bool isConnected = arguments[1];

      _onlineUsers[userId] = isConnected;
    }
  }
}

class _EventTypes {
  static const OnMessage = 'OnMessage';
  static const OnUnreadMessages = 'OnUpdateUnreadMessages';
}
