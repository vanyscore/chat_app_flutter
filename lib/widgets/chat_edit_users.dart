import 'package:chat_app/interactors/chat_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/screens/tab_screens/profile_screen.dart';
import 'package:chat_app/widgets/avatar.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatUsersEdit extends StatefulWidget {
  final ChatInfo chatInfo;

  ChatUsersEdit(this.chatInfo);

  @override
  State<StatefulWidget> createState() {
    return _ChatUsersEditState();
  }
}

class _ChatUsersEditState extends State<ChatUsersEdit> {
  late final int? userId;

  @override
  initState() {
    context
        .read<UserManager>()
        .getUserId()
        .then((value) => setState(() => userId = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          context.read<ChatInteractor>().getEditChatUsers(widget.chatInfo.id),
      builder: _getContent,
    );
  }

  Widget _getContent(
      BuildContext context, AsyncSnapshot<List<ChatUserEdit>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.done && userId != null) {
      final data = snapshot.data;

      if (data != null) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final user = data[index];

            return Column(
              children: [
                _ChatUser(user),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey,
                )
              ],
            );
          },
        );
      } else {
        return Center(
          child: Text("Список пуст"),
        );
      }
    } else {
      return DefaultProgressBar();
    }
  }
}

class _ChatUser extends StatefulWidget {
  final ChatUserEdit user;

  _ChatUser(this.user);

  @override
  State<StatefulWidget> createState() {
    return _ChatUserState();
  }
}

class _ChatUserState extends State<_ChatUser> {
  late bool _isAttached;

  @override
  initState() {
    _isAttached = widget.user.isAttached;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatInfo =
        context.findAncestorWidgetOfExactType<ChatUsersEdit>()!.chatInfo;
    final userId =
        context.findAncestorStateOfType<_ChatUsersEditState>()!.userId!;

    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: widget.user.userId)));
      },
      title: Row(
        children: [
          Text(widget.user.name),
          if (chatInfo.ownerId == widget.user.userId) ...{
            SizedBox(
              width: 10,
            ),
            Text(
              'Владелец',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          }
        ],
      ),
      leading: Avatar(widget.user.imageUrl,
          context.read<ChatConnection>().isUserOnline(widget.user.userId), 30),
      trailing: userId == chatInfo.ownerId && userId != widget.user.userId
          ? _ControlButton(_isAttached, onTap: (isAttached) async {
              final result = await context
                  .read<ChatInteractor>()
                  .updateChatUser(
                      context
                          .findAncestorWidgetOfExactType<ChatUsersEdit>()!
                          .chatInfo
                          .id,
                      widget.user.userId,
                      isAttached);

              if (result.value == null) {
                setState(() {
                  _isAttached = !_isAttached;
                });
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result.value!)));
              }
            })
          : null,
    );
  }
}

class _ControlButton extends StatelessWidget {
  final bool isAttached;
  final Function(bool isAttached) onTap;

  _ControlButton(this.isAttached, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          onTap(!isAttached);
        },
        icon: Icon(isAttached ? Icons.delete : Icons.add),
        color: isAttached ? Colors.red : Colors.green);
  }
}
