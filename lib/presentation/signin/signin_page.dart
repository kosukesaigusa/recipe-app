import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/signin/signin_model.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (_) => SignInModel()..fetchSignIn(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("ログイン"),
        ),
        body: Text('ログインページ'),
      ),
    );
  }
}
