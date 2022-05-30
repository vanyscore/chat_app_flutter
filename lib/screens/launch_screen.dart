import 'package:chat_app/managers/user_manager.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LaunchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LaunchState();
  }
}

class _LaunchState extends State<LaunchScreen> {
  late final Future<String?> _token;

  @override
  initState() {
    super.initState();

    _token = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _token,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        final Widget widget;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            widget = MainScreen();
          } else {
            widget = LoginScreen();
          }
        } else {
          widget = _Splash();
        }

        return widget;
      },
    );
  }

  Future<String?> _load() async {
    await Future.delayed(Duration(seconds: 2));

    final token = await context.read<UserManager>().getAccessToken();

    return token;
  }
}

class _Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Theme.of(context).primaryColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      color: Colors.white,
                      size: 100,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Чат',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '.NET Core\nFlutter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 25,
                bottom: 25,
                child: Text(
                  'Автор работы:\nИ.А. Пичугин\n\nЧелябинск 2022',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
              )
            ],
          )),
    );
  }
}
