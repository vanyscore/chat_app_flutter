import 'package:chat_app/dialogs/create_chat_dialog.dart';
import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/managers.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:chat_app/widgets/avatar.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsState();
  }
}

class _ChatsState extends State<ChatsScreen> {
  List<ChatInfo> _chats = List.empty(growable: true);
  bool _isLoading = true;
  late int _userId;

  @override
  initState() {
    super.initState();

    context.read<ChatConnection>().listenMessages(_onNewMessage);

    WidgetsBinding?.instance.addPostFrameCallback((timeStamp) {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? DefaultProgressBar() : _getChatList(_chats);
  }

  Widget _getChatList(List<ChatInfo> chats) {
    return RefreshIndicator(
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];

              return !chat.isPrivate
                  ? _CommonChatCard(chat)
                  : _PrivateChatCard(chat);
            },
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(right: 20, bottom: 20),
                child: Builder(
                  builder: (context) => FloatingActionButton(
                    onPressed: () async {
                      final chatName = await showDialog<String?>(
                          context: context,
                          builder: (context) {
                            return CreateChatDialog();
                          });

                      if (chatName != null && chatName.isNotEmpty) {
                        final result = await context
                            .read<ChatInteractor>()
                            .createChat(chatName);

                        if (result == null) {
                          _load();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result),
                          ));
                        }
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ))
        ],
      ),
      onRefresh: () async {
        _load();
      },
    );
  }

  @override
  deactivate() {
    context.read<ChatConnection>().disableMessageListening(_onNewMessage);

    super.deactivate();
  }

  _load() async {
    _userId = (await context.read<UserManager>().getUserId())!;

    context.read<ChatInteractor>().getChats().then((entry) {
      final chats = entry.key;

      if (chats != null) {
        final hub = context.read<ChatConnection>();

        chats.forEach((element) {
          hub.connectToChat(element.id);
        });

        setState(() {
          _chats.clear();
          _chats.addAll(chats);

          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(entry.value ?? 'Unknown error')));
      }
    });
  }

  _onNewMessage(ChatMessage message) {
    setState(() {
      try {
        _chats
            .where((element) => element.id == message.chatId)
            .forEach((element) {
          element.lastMessage = message;
          element.unreadMessages++;
        });
      } catch (ex, st) {
        print(ex.toString());
      }

      if (_chats.where((element) => element.id == message.chatId).isEmpty) {
        _load();
      }
    });
  }
}

class _CommonChatCard extends StatelessWidget {
  final ChatInfo chat;

  _CommonChatCard(this.chat);

  @override
  Widget build(BuildContext context) {
    final len = (chat.users.length > 5 ? 5 : chat.users.length) + 1;
    final lastMsgSenderName = chat.lastMessageSenderName;
    final lastMsgDesc = chat.lastMessageDesc;

    final isOurMsg = context.findAncestorStateOfType<_ChatsState>()?._userId ==
        chat.lastMessage?.senderId;

    return Card(
        child: InkWell(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen(chat.id)));

              context.findAncestorStateOfType<_ChatsState>()?._load();
            },
            child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 150,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Чат:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(child: Text(chat.name))
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Участники:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(width: 10),
                                  Text(chat.users.length.toString())
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 20,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: len,
                                  itemBuilder: (context, index) {
                                    if (index < len - 1) {
                                      final user = chat.users[index];

                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.5),
                                        child: Avatar(
                                            user.imageUrl,
                                            context
                                                .read<ChatConnection>()
                                                .isUserOnline(user.id),
                                            20),
                                      );
                                    } else {
                                      return Text('  ...');
                                    }
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        if (chat.unreadMessages > 0) ...{
                          Container(
                            height: 24,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(90)),
                            child: Center(
                              child: Text(
                                '+' + chat.unreadMessages.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        }
                      ],
                    ),
                    if (lastMsgSenderName != null) ...{
                      SizedBox(
                        height: 2.5,
                      ),
                      Row(
                        children: [
                          Text(
                            isOurMsg ? 'Вы:' : lastMsgSenderName + ':',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lastMsgDesc!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                      )
                    }
                  ],
                ))));
  }
}

class _PrivateChatCard extends StatelessWidget {
  final ChatInfo chat;

  _PrivateChatCard(this.chat);

  @override
  Widget build(BuildContext context) {
    final len = (chat.users.length > 5 ? 5 : chat.users.length) + 1;
    final userTo = chat.users.singleWhere((element) =>
        element.id != context.findAncestorStateOfType<_ChatsState>()!._userId);
    final lastMsgSenderName = chat.lastMessageSenderName;
    final lastMsgDesc = chat.lastMessageDesc;

    final isOurMsg = context.findAncestorStateOfType<_ChatsState>()?._userId ==
        chat.lastMessage?.senderId;

    return Card(
        child: InkWell(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen(chat.id)));

              context.findAncestorStateOfType<_ChatsState>()?._load();
            },
            child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5),
                      child: Avatar(
                          userTo.imageUrl,
                          context
                              .read<ChatConnection>()
                              .isUserOnline(userTo.id),
                          48),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${userTo.name}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Flexible(child: Text(chat.name)),
                            ],
                          ),
                          if (lastMsgSenderName != null) ...{
                            if (isOurMsg) ...{
                              Text(
                                "Вы",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            },
                            SizedBox(
                              height: 2.5,
                            ),
                            Text(
                              "$lastMsgDesc",
                              style: TextStyle(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          }
                        ],
                      ),
                    ),
                    if (chat.unreadMessages > 0) ...{
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              height: 24,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(90)),
                              child: Center(
                                child: Text(
                                  '+' + chat.unreadMessages.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                      )
                    }
                  ],
                ))));
  }
}
