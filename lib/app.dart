import 'package:chat_app/api/token_interceptor.dart';
import 'package:chat_app/interactors/interactors.dart';
import 'package:chat_app/managers/managers.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  final String host;
  final int port;

  App({required this.host, required this.port});

  @override
  State<App> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => UserManager()),
        Provider(
          create: (context) => Dio()
            ..options.baseUrl = 'http://${widget.host}:${widget.port}/'
            ..interceptors.add(TokenInterceptor(context.read<UserManager>())),
        ),
        Provider(
          create: (context) =>
              AuthInteractor(context.read<Dio>(), context.read<UserManager>()),
        ),
        Provider(
          create: (context) => UserInteractor(context.read<Dio>()),
        ),
        Provider(
          create: (context) => ChatInteractor(
              userInteractor: context.read<UserInteractor>(),
              userManager: context.read<UserManager>(),
              dio: context.read<Dio>()),
        ),
        Provider<ChatConnection>(
          create: (context) => ChatConnection(context.read<UserManager>(),
              host: widget.host, port: widget.port),
          dispose: (context, connection) => connection.disconnect(),
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => LaunchScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/main': (context) => MainScreen()
          }),
    );
  }
}
