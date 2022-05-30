import 'package:chat_app/dialogs/avatar_dialog.dart';
import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/widgets/avatar.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessagesList extends StatefulWidget {
  final ChatUiModel model;

  ChatMessagesList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ChatMessagesState(model);
  }
}

class _ChatMessagesState extends State<ChatMessagesList> {
  final ChatUiModel model;
  final List<ChatMessageUiModel> _messages = List.empty(growable: true);
  final ScrollController _scrollController = ScrollController();

  String? accessToken;

  _ChatMessagesState(this.model);

  @override
  initState() {
    super.initState();

    WidgetsBinding?.instance.addPostFrameCallback((timeStamp) {
      context.read<ChatConnection>().listenMessages(_onNewMessage);
      context
          .read<UserManager>()
          .getAccessToken()
          .then((value) => setState(() => accessToken = value));

      context
          .read<ChatInteractor>()
          .getChatMessages(model.chatInfo.id)
          .then((value) {
        setState(() {
          _messages.addAll(value.map((msg) => ChatMessageUiModel(
              msg,
              model.chatInfo.allUsers
                  .singleWhere((element) => msg.senderId == element.id),
              msg.senderId == model.profileInfo.id)));

          _scrollDown(afterAction: () {
            if (_messages.isNotEmpty) {
              _readMessage(_messages.last.messageInfo.id);
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_messages.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: _messages.length,
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return ChatMessageTile(_messages[index]);
        },
      );
    } else {
      return Center(
        child: Text("История сообщений пуста"),
      );
    }
  }

  @override
  deactivate() {
    context.read<ChatConnection>().disableMessageListening(_onNewMessage);

    super.deactivate();
  }

  void _onNewMessage(ChatMessage msg) {
    print('chat_messages onNewMessage()');

    setState(() {
      final uiMsg = ChatMessageUiModel(
          msg,
          model.chatInfo.allUsers.singleWhere((usr) => usr.id == msg.senderId),
          msg.senderId == model.profileInfo.id);
      _messages.add(uiMsg);

      _scrollDown(afterAction: () => _readMessage(msg.id));
    });
  }

  _readMessage(int id) {
    final dio = context.read<Dio>();

    try {
      dio.patch('api/chat/${model.chatInfo.id}/read/${id}');
    } catch (ex, st) {
      print(ex.toString() + '\n$st');
    }
  }

  _scrollDown({VoidCallback? afterAction}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      afterAction?.call();
    });
  }
}

class ChatMessageTile extends StatelessWidget {
  final ChatMessageUiModel model;

  ChatMessageTile(this.model);

  @override
  Widget build(BuildContext context) {
    return _getMessageContent();
  }

  Widget _getMessageContent() {
    if (!model.isOurMessage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(builder: (context) {
            return Avatar(
                model.senderInfo.imageUrl,
                context
                    .read<ChatConnection>()
                    .isUserOnline(model.senderInfo.id),
                30);
          }),
          SizedBox(
            width: 5,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Card(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            model.senderInfo.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            model.date,
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _getContentOfMessage()
                    ],
                  )),
            ),
          )
        ],
      );
    } else {
      return Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            model.date,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Вы",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _getContentOfMessage()
                    ],
                  )),
            )
          ],
        ),
      );
    }
  }

  Widget _getContentOfMessage() {
    return Builder(builder: (context) {
      if (model.messageInfo.message != null) {
        return Text(
          model.messageInfo.message!,
          textAlign: TextAlign.right,
        );
      }

      if (model.messageInfo.image != null) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        AvatarDialog(model.messageInfo.image!));
              },
              child: Image.network(model.messageInfo.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250, loadingBuilder: (context, widget, event) {
                return event?.cumulativeBytesLoaded == event?.expectedTotalBytes
                    ? widget
                    : DefaultProgressBar();
              }, headers: {
                'Authorization':
                    'Bearer ${context.findAncestorStateOfType<_ChatMessagesState>()?.accessToken ?? ''}'
              }),
            ),
          ),
        );
      }

      return SizedBox();
    });
  }
}
