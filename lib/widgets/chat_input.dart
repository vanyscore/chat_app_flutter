import 'package:chat_app/managers/chat_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatInput extends StatefulWidget {
  final int chatId;

  ChatInput(this.chatId);

  @override
  State<StatefulWidget> createState() {
    return _ChatInputState(chatId);
  }
}

class _ChatInputState extends State<ChatInput> {
  StringBuffer _message = StringBuffer();
  String? _error;
  TextEditingController _controller = TextEditingController();

  final int chatId;

  _ChatInputState(this.chatId);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  errorText: _error,
                  hintText: "Введите текст сообщения",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
              onChanged: (text) {
                _message.clear();
                _message.write(text);

                setState(() {
                  _error = null;
                });
              },
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: FloatingActionButton(
              onPressed: () {
                if (_message.isNotEmpty) {
                  context
                      .read<ChatConnection>()
                      .sendMessage(chatId, _message.toString());

                  FocusScope.of(context).unfocus();

                  setState(() {
                    _message.clear();
                    _controller.clear();
                  });
                } else {
                  setState(() {
                    _error = "Текст сообщения не должен быть пуст";
                  });
                }
              },
              child: Icon(Icons.send),
            ),
          )
        ],
      ),
    );
  }
}
