import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/password_update/password_update_page.dart';

class PasswordUpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasswordUpdateModel>(
      create: (_) => PasswordUpdateModel()..fetchPasswordUpdate(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("パスワードの更新"),
        ),
        body: Text('パスワードの更新ページ'),
      ),
    );
  }
}
