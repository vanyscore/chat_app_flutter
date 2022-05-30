import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(),
      ),
    );
  }
}