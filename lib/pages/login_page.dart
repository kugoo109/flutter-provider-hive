import 'dart:convert';

import 'package:flutter_sample/services/users.dart';
import 'package:flutter_sample/stores/settings.dart';
import 'package:flutter_sample/widgets/error_text.dart';
import 'package:flutter_sample/widgets/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample/helpers/field_errors.dart';
import 'package:flutter_sample/helpers/toast.dart';
import 'package:flutter_sample/widgets/buttons.dart';
import 'package:flutter_sample/widgets/outline_input.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController tfEmail = TextEditingController(), tfPassword = TextEditingController();

  List<FieldError> errors = [];
  bool loading = false;
  bool isPasswordShow = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    init();
  }

  @override
  void dispose() {
    tfEmail.dispose();
    tfPassword.dispose();
    super.dispose();
  }

  init() async {}

  validate(String email, String password) {
    errors.clear();

    if (email.isEmpty) {
      errors.add(new FieldError(field: 'email', message: 'Email is missing.'));
    }

    if (password.isEmpty) {
      errors.add(new FieldError(field: 'password', message: 'Password is missing.'));
    }

    this.setState(() {});

    return errors.length == 0;
  }

  handleLogin() async {
    var email = tfEmail.text;
    var password = tfPassword.text;

    var isValid = validate(email, password);
    if (isValid) {
      setState(() {
        loading = true;
      });

      var response = await UserApi.login(email, password);

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var token = body['token'];
        var name = body['name'];
        var email = body['email'];

        await context.read<Settings>().updateAuth(token, name, email);

        Navigator.pop(context);
        showToastSuccess("Login successfully");
      } else if (response.statusCode == 400) {
        errors.add(new FieldError(field: 'login', message: 'Invalid request.'));
      } else {
        showToastError("Login failed");
      }

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 64),
            Image.asset(
              "assets/images/logo.png",
              height: 64,
              width: 64,
            ),
            SizedBox(height: 16),
            Logo(),
            SizedBox(height: 64),
            OutlineInput(
              controller: tfEmail,
              keyboardType: TextInputType.text,
              hintText: 'Email',
              errorText: getFirstError(errors, 'email')?.message,
            ),
            SizedBox(height: 8),
            OutlineInput(
              controller: tfPassword,
              keyboardType: TextInputType.text,
              obscureText: !isPasswordShow,
              hintText: 'Password',
              errorText: getFirstError(errors, 'password')?.message,
            ),
            SizedBox(height: 8),
            ErrorText(text: getFirstError(errors, 'login')?.message),
            Button(
              disabled: loading,
              title: loading ? 'Logining...' : 'Login',
              action: () {
                handleLogin();
              },
            ),
            SizedBox(height: 8),
            Button(
              title: 'Register',
              action: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
            )
          ],
        ),
      ),
    );
  }
}
