import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/widgets/chat_app_bar.dart';
import 'package:chat_app/widgets/chat_input.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;

  ChatScreen(this.chatId);

  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<ChatScreen> {
  late ChatUiModel chatData;
  late int? userId;

  @override
  initState() {
    super.initState();

    WidgetsBinding?.instance.addPostFrameCallback((timeStamp) {
      context.read<ChatConnection>().connectToChat(widget.chatId);
      context
          .read<UserManager>()
          .getUserId()
          .then((value) => setState(() => userId = value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ChatInteractor>().getUiData(widget.chatId),
      builder: (context, snapshot) {
        Widget defaultWidget = Scaffold(
          appBar: AppBar(
            title: Text("Загрузка чата"),
            leading: Icon(Icons.assignment_ind),
          ),
          body: DefaultProgressBar(),
        );

        if (snapshot.connectionState == ConnectionState.done &&
            userId != null) {
          if (snapshot.hasData) {
            final data = snapshot.data as ChatUiModel;

            chatData = data;

            defaultWidget = Scaffold(
                body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ChatAppBar(data.chatInfo.id, data.chatInfo.name,
                    data.profileInfo.imageUrl),
                Expanded(child: ChatMessagesList(data)),
                ChatInput(widget.chatId)
              ],
            ));
          }
        }

        return defaultWidget;
      },
    );
  }
}
