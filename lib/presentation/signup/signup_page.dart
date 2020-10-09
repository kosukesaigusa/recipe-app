import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/signup/signup_model.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpModel>(
      create: (_) => SignUpModel()..fetchSignUp(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("新規登録"),
        ),
        body: Text('新規登録ページ'),
      ),
    );
  }
}
