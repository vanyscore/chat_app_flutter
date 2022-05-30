import 'package:chat_app/dialogs/avatar_dialog.dart';
import 'package:chat_app/interactors/user_interactor.dart';
import 'package:chat_app/managers/chat_connection.dart';
import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/models/api_responses.dart';
import 'package:chat_app/widgets/default_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;

  ProfileScreen({this.userId});

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  UserInfo? _profile;
  String? _accessToken;

  @override
  initState() {
    super.initState();

    makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return _profile == null
        ? DefaultProgressBar()
        : _accessToken != null
            ? _ProfileInfo()
            : _OtherProfileScreen();
  }

  void makeRequest() async {
    if (widget.userId == null) {
      final token = await context.read<UserManager>().getAccessToken();
      final profile = await context.read<UserInteractor>().getUserInfo();

      setState(() {
        _profile = profile;
        _accessToken = token;
      });
    } else {
      final user =
          (await context.read<UserInteractor>().getUser(widget.userId!)).key;

      if (user != null) {
        setState(() {
          _profile = user;
        });
      }
    }
  }
}

class _OtherProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Профиль'),
        ),
        body: _ProfileInfo(),
      );
}

class _ProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.findAncestorStateOfType<_ProfileState>()?._profile!;

    final state = context.findAncestorStateOfType<_ProfileState>();

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: GestureDetector(
                      child: Image.network(
                        profile!.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                AvatarDialog(profile.imageUrl));
                      },
                    ))),
            if (state?._accessToken != null) ...{
              ElevatedButton(
                  onPressed: () async {
                    final image = await ImagePicker().getImage(
                      source: ImageSource.gallery,
                    );

                    if (image != null) {
                      final result = await context
                          .read<UserInteractor>()
                          .updateImage(profile.id, image.path);

                      if (result == null) {
                        state?.setState(() {
                          state._profile = null;
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      }
                    }
                  },
                  child: Text("Сменить изображение профиля"))
            } else ...{
              SizedBox(
                height: 10,
              )
            },
            _ProfileRow(title: "Имя:", description: profile.name),
            _ProfileRow(
                title: "Электронная почта:", description: profile.email),
            _ProfileRow(
                title: "Номер телефона:", description: profile.telephone),
            if (state?._accessToken != null) ...{
              Card(
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 3.0)),
                      child: Row(
                        children: [
                          Text(
                            "JWT ключ:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(state!._accessToken!),
                            ),
                          )
                        ],
                      ))),
              ElevatedButton(
                onPressed: () async {
                  await context.read<ChatConnection>().disconnect();

                  context.read<UserManager>().clear().then((isCleared) {
                    if (isCleared) Navigator.popAndPushNamed(context, '/');
                  }).onError((error, stackTrace) {
                    print("Error: " + error.toString());
                  });
                },
                child: Text("Выход"),
              )
            },
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String title;
  final String description;

  _ProfileRow({required this.title, required this.description});

  @override
  Widget build(BuildContext context) => Card(
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Text(description))
            ])),
      );
}
