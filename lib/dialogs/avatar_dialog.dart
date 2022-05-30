import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarDialog extends StatelessWidget {
  final String imageUrl;

  AvatarDialog(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      content: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}
