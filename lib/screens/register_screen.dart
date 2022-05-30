import 'package:chat_app/interactors/auth_interactor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<RegisterScreen> {
  Map<String, dynamic> _validations = Map<String, dynamic>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordOneController = TextEditingController();
  final _passwordTwoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "Введите имя",
                        errorText: _validations["name"]),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "Введите почту",
                        errorText: _validations["email"]),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        hintText: "Введите номер телефона",
                        errorText: _validations["telephone"]),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                      controller: _passwordOneController,
                      decoration: InputDecoration(
                          hintText: "Введите пароль",
                          errorText: _validations["pswOne"]),
                      obscureText: true),
                  TextFormField(
                    controller: _passwordTwoController,
                    decoration: InputDecoration(
                        hintText: "Повторите пароль",
                        errorText: _validations["pswTwo"]),
                    obscureText: true,
                  ),
                  ElevatedButton(
                      onPressed: _handleRegisterClick,
                      child: Text("Зарегестрироваться"))
                ],
              ),
            ),
          )),
    );
  }

  _handleRegisterClick() async {
    final validations = Map<String, String>();
    final emptyString = "Поле не должно быть пустым";

    var isValid = true;

    if (_nameController.text.isEmpty) {
      validations["name"] = emptyString;
      isValid = false;
    }

    if (_emailController.text.isEmpty) {
      validations["email"] = emptyString;
      isValid = false;
    }

    if (_phoneController.text.isEmpty) {
      validations["telephone"] = emptyString;
      isValid = false;
    }

    if (_passwordOneController.text.isEmpty) {
      validations["pswOne"] = emptyString;
      isValid = false;
    }

    if (_passwordTwoController.text.isEmpty) {
      validations["pswTwo"] = emptyString;
      isValid = false;
    }

    if (_passwordOneController.text.isNotEmpty &&
        _passwordTwoController.text.isNotEmpty) {
      if (_passwordOneController.text.toString() !=
          _passwordTwoController.text.toString()) {
        final pswNotEqual = "Пароли не совпадают";

        validations["pswOne"] = pswNotEqual;
        validations["pswTwo"] = pswNotEqual;

        isValid = false;
      }
    }

    if (isValid) {
      final authResult = await context.read<AuthInteractor>().register(
          _nameController.text.toString(),
          _emailController.text.toString(),
          _phoneController.text.toString(),
          _passwordOneController.text.toString());

      if (authResult.data != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (r) => false);
      }

      if (authResult.validations != null) {
        setState(() {
          _validations = authResult.validations!;
        });
      }

      if (authResult.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authResult.errorMessage!)));
      }
    } else {
      setState(() {
        _validations = validations;
      });
    }
  }
}
