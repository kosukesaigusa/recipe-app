import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_model.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactModel>(
      create: (_) => ContactModel()..fetchContact(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("お問い合わせ"),
        ),
        body: Text('お問い合わせページ'),
      ),
    );
  }
}
