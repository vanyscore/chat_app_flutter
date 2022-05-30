import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:signalr_core/signalr_core.dart';

typedef OnNewMessageCallback = void Function(ChatMessage message);
typedef OnUpdateUnreadMessages = void Function(int? unreadMessages);
typedef OnChatUpdated = void Function(ChatInfo chat, bool isAdd);

class ChatConnection {
  final UserManager userManager;
  final String host;
  final int port;

  HubConnection? _connection;

  ChatConnection(this.userManager, {required this.host, required this.port});

  List<OnNewMessageCallback> _onMessageHandlers = List.empty(growable: true);
  List<OnUpdateUnreadMessages> _unreadMessagesHandlers =
      List.empty(growable: true);
  List<OnChatUpdated> _onChatAddedHandlers = List.empty(growable: true);

  Map<int, bool> _onlineUsers = new Map();

  bool isUserOnline(int userId) {
    return _onlineUsers[userId] ?? false;
  }

  connectToChat(int chatId) async {
    await _connection!.send(methodName: "ConnectToChat", args: [chatId]);
  }

  listenMessages(OnNewMessageCallback onMessage) async {
    _onMessageHandlers.add(onMessage);
  }

  disableMessageListening(OnNewMessageCallback callback) async {
    print('result on message handlers len: ${_onMessageHandlers.length}');

    _onMessageHandlers.remove(callback);

    print(
        'result on message handlers len after remove callback: ${_onMessageHandlers.length}');
  }

  listenOnUpdateUnreadMessages(
      OnUpdateUnreadMessages onUpdateUnreadMessages) async {
    print('listenOnUpdateUnreadMessages');

    _unreadMessagesHandlers.add(onUpdateUnreadMessages);
  }

  listenOnChatAdded(OnChatUpdated callback) {
    _onChatAddedHandlers.add(callback);
  }

  disableOnUpdateUnreadMessages(OnUpdateUnreadMessages callback) async {
    _unreadMessagesHandlers.remove(callback);
  }

  disableOnChatAddedHandle(OnChatUpdated callback) {
    _onChatAddedHandlers.remove(callback);
  }

  sendMessage(int chatId, String message) async {
    if (_connection?.state == HubConnectionState.connected) {
      await _connection!.send(methodName: "Send", args: [chatId, message]);
    }
  }

  connect() async {
    try {
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
      _connection!.on(_EventTypes.OnUnreadMessages, _onUnreadMessages);
      _connection!.on(_EventTypes.OnChatUpdated, _onChatUpdated);

      _connection?.on("UserConnection", _onUserConnectionChanged);

      await _connection?.start();
    } catch (ex, trace) {
      print(ex.toString());
      print(trace);
    }
  }

  disconnect() async {
    _onMessageHandlers.clear();
    _unreadMessagesHandlers.clear();
    _onlineUsers.clear();

    await _connection?.stop();
    _connection = null;
  }

  void _onMessage(List<dynamic>? arguments) {
    print('Event: ${_EventTypes.OnMessage}: ' + arguments.toString());

    final json = arguments![0]["value"];

    final msg = ChatMessage.fromJson(json);

    print('onMsgHandlers len: ${_onMessageHandlers.length}');

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

  _onChatUpdated(List<dynamic>? arguments) {
    print('Event: ${_EventTypes.OnChatUpdated}: ' + arguments.toString());

    final chatInfo = ChatInfo.fromJson(arguments![0]['value']);
    final isAdd = arguments[1] as bool;

    print('isAdd: $isAdd');

    _onChatAddedHandlers.forEach((element) {
      element.call(chatInfo, isAdd);
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
  static const OnChatUpdated = 'OnChatUpdated';
}
