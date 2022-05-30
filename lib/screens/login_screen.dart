import 'package:chat_app/interactors/auth_interactor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _loginError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Авторизация")),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                      controller: _loginController,
                      decoration: InputDecoration(
                          hintText: "Введите номер телефона/почту",
                          errorText: _loginError),
                      onChanged: (text) {
                        if (text.isNotEmpty && _loginError != null) {
                          setState(() {
                            _loginError = null;
                          });
                        }
                      }),
                  TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: "Введите пароль",
                          errorText: _passwordError),
                      obscureText: true,
                      onChanged: (text) {
                        if (text.isNotEmpty && _passwordError != null) {
                          setState(() {
                            _passwordError = null;
                          });
                        }
                      }),
                  ElevatedButton(
                    onPressed: _handleAuthorization,
                    child: Text("Войти"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text("Регистрация"))
                ],
              ),
            )));
  }

  _handleAuthorization() async {
    final login = _loginController.text;
    final password = _passwordController.text;
    var isValid = true;

    if (login.isEmpty) {
      setState(() {
        _loginError = "Данное поле не должно быть пустым";
      });

      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = "Пароль не должен быть пустым";
      });

      isValid = false;
    }

    if (!isValid) {
      return;
    } else {
      setState(() {
        _loginError = null;
        _passwordError = null;
      });

      FocusScope.of(context).unfocus();

      final authResult = await context.read<AuthInteractor>().login(
            login,
            password,
          );

      if (authResult.data != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (r) => false);
      }

      if (authResult.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authResult.errorMessage!)));
      }
    }
  }
}
