import 'package:chat_app/app.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(App(
    host: '192.168.0.4',
    port: 16214,
  ));
}
