import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {

  final String avatarUrl;
  final bool isOnline;
  final double size;

  Avatar(this.avatarUrl, this.isOnline, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            image: DecorationImage(
                image: NetworkImage(
                    avatarUrl
                ),
                fit: BoxFit.cover
            ),
            border: Border.all(
                color: _getColor(),
                width: 2
            )
        ),
    );
  }

  Color _getColor() {
    if (isOnline) return Colors.green;
    else return Colors.transparent;
  }
}