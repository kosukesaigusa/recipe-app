import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/my_account/my_account_model.dart';

class MyAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAccountModel>(
      create: (_) => MyAccountModel()..fetchMyAccount(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("マイページ"),
        ),
        body: Text('マイページ'),
      ),
    );
  }
}
