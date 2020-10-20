import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

import 'link_anonymous_user_model.dart';

class LinkAnonymousUserPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController(); //パスワード（確認用）

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LinkAnonymousUserModel>(
      create: (_) => LinkAnonymousUserModel()..fetchPasswordUpdate(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("ユーザー登録"),
        ),
        body: Consumer<LinkAnonymousUserModel>(
          builder: (context, model, child) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //メールアドレス
                    TextFormField(
                      controller: mailController,
                      onChanged: (text) {
                        model.mail = text;
                      },
                      obscureText: true,
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
                    TextFormField(
                      controller: confirmController,
                      onChanged: (text) {
                        model.confirm = text;
                      },
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'パスワード（確認用）',
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
                        child: Text('ユーザー登録する'),
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () async {
                          try {
                            await model.linkAnonymousUser();
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      'パスワードを変更しました。新しいパスワードで再度ログインして下さい。'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            _showTextDialog(context, e.toString());
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
