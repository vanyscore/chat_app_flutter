import 'package:chat_app/interactors/chat_interactor.dart';
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
  final String imageUrl;

  ChatAppBar(this.chatId, this.name, this.imageUrl);

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
              );

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
          if (userId == chatData.chatInfo.ownerId) ...{
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
          Avatar(imageUrl, true, 30)
        ],
      ),
    );
  }
}
