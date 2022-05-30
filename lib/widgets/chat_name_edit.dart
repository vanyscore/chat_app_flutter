import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatNameEdit extends StatefulWidget {
  final int chatId;

  ChatNameEdit(this.chatId);

  @override
  State<StatefulWidget> createState() {
    return _ChatNameEditState(chatId);
  }
}

class _ChatNameEditState extends State<ChatNameEdit> {
  final int chatId;
  late final TextEditingController controller;
  String? error;

  _ChatNameEditState(this.chatId) {
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<ChatInteractor>().getChat(chatId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data as MapEntry<ChatInfo?, String?>;

            if (data.key != null) {
              final name = data.key!.name;

              controller.text = name;

              return _getForm();
            } else {
              controller.text = "Ошибка";

              return _getForm();
            }
          } else {
            return _getForm();
          }
        });
  }

  Widget _getForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
            controller: controller,
            decoration: InputDecoration(
                hintText: "Введите название чат комнаты", errorText: error)),
        ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final result = await context
                    .read<ChatInteractor>()
                    .updateChatName(chatId, controller.text);

                if (result == null) {
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(result),
                  ));
                }
              } else {
                setState(() {
                  error = "Название чата не должно быть пустым";
                });
              }

              FocusScope.of(context).unfocus();
            },
            child: Text("Сохранить название"))
      ],
    );
  }
}
