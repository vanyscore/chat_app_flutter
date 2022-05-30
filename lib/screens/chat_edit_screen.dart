import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/widgets/chat_edit_users.dart';
import 'package:chat_app/widgets/chat_name_edit.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatEditScreen extends StatefulWidget {
  final int chatId;

  ChatEditScreen(this.chatId);

  @override
  State<StatefulWidget> createState() {
    return _ChatEditState();
  }
}

class _ChatEditState extends State<ChatEditScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ChatInteractor>().getChat(widget.chatId),
      builder: _getChatInfo,
    );
  }

  Widget _getChatInfo(BuildContext context,
      AsyncSnapshot<MapEntry<ChatInfo?, String?>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      final data = snapshot.data;

      if (data != null) {
        final chatInfo = data.key;

        if (chatInfo != null) {
          return Scaffold(
            appBar: AppBar(title: Text("Редактирование чата")),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: ChatNameEdit(chatInfo.id),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Участники (удалить/добавить)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(child: ChatUsersEdit(chatInfo))
              ],
            ),
          );
        } else {
          _showError(data.value!);
        }
      } else {
        _showError("Ошибка");
      }
    }

    return Scaffold(
      body: DefaultProgressBar(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
