import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateChatDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _CreateChatState();
  }
}

class _CreateChatState extends State<CreateChatDialog> {

  StringBuffer _name = StringBuffer();
  String? _error;

  VoidCallback? _isEnabled;

  _CreateChatState() {
    _isEnabled = _onPressed;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(10),
      actionsPadding: EdgeInsets.all(0),
      title: Container(
        padding: EdgeInsets.all(10),
        color: Theme.of(context).accentColor,
        child: Text(
            "Создание чата",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      content: TextFormField(
        decoration: InputDecoration(
          hintText: "Введите название чата",
          errorText: _error
        ),
        onChanged: (text) {
          _name.clear();
          _name.write(text);
        },
      ),
      actions: [
        Container(
          width: double.maxFinite,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
              onPressed: _isEnabled
              , child: Text("Создать")),
        )
      ],
    );
  }

  void _onPressed() {
    _makeRequest();
  }

  Future<void> _makeRequest() async {
    if (_name.isEmpty) {
      setState(() {
        _error = "Поле не должно быть пустым";
      });

      return;
    } else {
      setState(() {
        _isEnabled = null;
      });

      Navigator.pop(context, _name.toString());

      setState(() {
        _isEnabled = _makeRequest;
      });
    }
  }
}