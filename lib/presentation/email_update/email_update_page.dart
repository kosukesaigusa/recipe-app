import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/email_update/email_update_model.dart';

class EmailUpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmailUpdateModel>(
      create: (_) => EmailUpdateModel()..fetchEmailUpdate(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('メールアドレスの更新'),
        ),
        body: Text('メールアドレスの更新ページ'),
      ),
    );
  }
}
