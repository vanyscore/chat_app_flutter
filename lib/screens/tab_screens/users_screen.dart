import 'package:chat_app/interactors/user_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/managers.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:chat_app/screens/tab_screens/profile_screen.dart';
import 'package:chat_app/widgets/avatar.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UsersState();
  }
}

class _UsersState extends State<UsersScreen> {
  late final int _userId;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<UserManager>().getUserId().then((value) {
        setState(() {
          _userId = value!;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: FutureBuilder(
          future: context.read<UserInteractor>().getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final users = snapshot.data as List<UserInfo>?;

              if (users != null && _userId > 0) {
                return ListView.builder(
                  itemBuilder: (context, index) => _UserCard(users[index]),
                  itemCount: users.length,
                );
              } else {
                return Center(
                  child: Text("Ошибка"),
                );
              }
            } else {
              return DefaultProgressBar();
            }
          },
        ),
        onRefresh: () async {
          setState(() {});

          return;
        });
  }
}

class _UserCard extends StatelessWidget {
  final UserInfo user;

  _UserCard(this.user);

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: user.id)));
          },
          leading: Avatar(user.imageUrl,
              context.read<ChatConnection>().isUserOnline(user.id), 50),
          title: Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(user.email),
          trailing:
              user.id != context.findAncestorStateOfType<_UsersState>()?._userId
                  ? IconButton(
                      onPressed: () {
                        _createChat(context);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.blue,
                      ))
                  : null,
        ),
      );

  _createChat(BuildContext context) async {
    try {
      final dio = context.read<Dio>();

      final resp = await dio.post('api/chat/private/create/${user.id}');
      final chatId = resp.data as int;

      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ChatScreen(chatId)));
    } catch (ex) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.toString())));
    }
  }
}
