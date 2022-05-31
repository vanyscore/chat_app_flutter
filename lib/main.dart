import 'package:chat_app/app.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(App(
    host: '*',
    port: 16214,
  ));
}
