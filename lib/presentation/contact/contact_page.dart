import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_model.dart';
import 'package:recipe/presentation/signup/signup_page.dart';

class ContactPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactModel>(
      create: (_) => ContactModel(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("お問い合わせ"),
        ),
        body: Consumer<ContactModel>(builder: (context, model, child) {
          return Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: mailController,
                  onChanged: (text) {
                    model.mail = text.trim();
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //パスワード
                TextFormField(
                  controller: passwordController,
                  onChanged: (text) {
                    model.password = text;
                  },
                  obscureText: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    // errorText: '８文字以上20文字以内',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    child: Text('ログイン'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        await model.login();
                      } catch (e) {
                        _showTextDialog(context, e.toString());
                      }
                    },
                  ),
                ),
                FlatButton(
                  child: Text(
                    '新規登録はこちら',
                  ),
                  textColor: Colors.blue,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ));
        }),
      ),
    );
  }
}

_showTextDialog(context, message) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
