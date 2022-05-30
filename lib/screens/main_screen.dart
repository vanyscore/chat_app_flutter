import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/screens/tab_screens/chats_screen.dart';
import 'package:chat_app/screens/tab_screens/profile_screen.dart';
import 'package:chat_app/screens/tab_screens/users_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart';

HubConnection? connection;

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainState();
  }
}

class _MainState extends State<MainScreen> {
  int _selectedInner = 0;

  int _unreadMessages = 0;

  @override
  initState() {
    super.initState();

    WidgetsBinding?.instance.addPostFrameCallback((timeStamp) {
      updateUnreadMessages();
    });
  }

  final Map<dynamic, Map<String, dynamic>> _inners = {
    0: {"title": "Профиль", "isNeedIcon": false, "screen": ProfileScreen()},
    1: {"title": "Чаты", "isNeedIcon": false, "screen": ChatsScreen()},
    2: {"title": "Пользователи", "isNeedIcon": false, "screen": UsersScreen()},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_inners[_selectedInner]!["title"]),
      ),
      body: _inners[_selectedInner]!["screen"],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_ind_outlined), label: "Профиль"),
          BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(child: Icon(Icons.chat_bubble_outline)),
                    if (_unreadMessages > 0) ...{
                      Positioned(
                        top: -10,
                        right: -12.5 -
                            ((_unreadMessages.toString().length - 1) * 7.5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(90)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.5, horizontal: 7.5),
                            child: Center(
                              child: Text(
                                _unreadMessages.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      )
                    }
                  ],
                ),
              ),
              label: "Чаты"),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle_rounded),
              label: "Пользователи"),
        ],
        onTap: (number) {
          setState(() {
            _selectedInner = number;
          });
        },
        currentIndex: _selectedInner,
      ),
    );
  }

  @override
  deactivate() {
    final hub = context.read<ChatConnection>();

    print('deactivate');

    hub.disableOnUpdateUnreadMessages(_onUpdateUnreadMessagesHandler);

    super.deactivate();
  }

  updateUnreadMessages() async {
    final hub = context.read<ChatConnection>();

    hub.listenOnUpdateUnreadMessages(_onUpdateUnreadMessagesHandler);

    _makeUnreadMessagesRequest();
  }

  _onUpdateUnreadMessagesHandler(int? unreadMessages) async {
    if (unreadMessages != null) {
      setState(() => _unreadMessages = unreadMessages);
    } else {
      _makeUnreadMessagesRequest();
    }
  }

  _makeUnreadMessagesRequest() async {
    try {
      final dio = context.read<Dio>();
      final resp = await dio.get('/api/chat/unreadMessages');

      print(resp.data);

      final unreadCount = resp.data as int;

      setState(() {
        _unreadMessages = unreadCount;
      });
    } catch (ex, st) {
      print(ex.toString() + '\n$st');
    }
  }
}
