import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/screens/chat_edit_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatelessWidget {
  final int chatId;
  final String name;
  final int? toId;
  final String? toImageUrl;
  final String fromImageUrl;

  ChatAppBar(this.chatId, this.name, this.fromImageUrl,
      {this.toImageUrl, this.toId});

  @override
  Widget build(BuildContext context) {
    final chatState = context.findAncestorStateOfType<ChatState>()!;
    final chatData = chatState.chatData;
    final userId = chatState.userId;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      padding: EdgeInsets.only(
          right: 10, top: MediaQuery.of(context).padding.top + 5, bottom: 5),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
              )),
          if (toImageUrl != null) ...{
            Avatar(toImageUrl!,
                context.read<ChatConnection>().isUserOnline(toId!), 30),
            SizedBox(
              width: 10,
            )
          },
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () async {
              final image = await ImagePicker().getImage(
                  source: ImageSource.gallery,
                  maxHeight: 1000,
                  maxWidth: 1000,
                  imageQuality: 75);

              if (image != null) {
                context
                    .read<ChatInteractor>()
                    .sendImageToChat(chatData.chatInfo.id, image.path);
              }
            },
            icon: Icon(
              Icons.attach_file,
              color: Colors.white,
            ),
          ),
          if (!chatData.chatInfo.isPrivate &&
              userId == chatData.chatInfo.ownerId) ...{
            IconButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatEditScreen(chatId)));

                  context.findAncestorStateOfType<ChatState>()?.setState(() {});
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ))
          },
          Avatar(fromImageUrl, true, 30)
        ],
      ),
    );
  }
}
