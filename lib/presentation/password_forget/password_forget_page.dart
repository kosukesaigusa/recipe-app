import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/password_forget/password_forget_model.dart';

class ForgetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgetPasswordModel>(
      create: (_) => ForgetPasswordModel()..fetchForgetPassword(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("パスワードの再設定"),
        ),
        body: Text('パスワードの再設定ページ'),
      ),
    );
  }
}
