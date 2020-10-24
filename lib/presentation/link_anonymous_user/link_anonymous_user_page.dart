import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'link_anonymous_user_model.dart';

class LinkAnonymousUserPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController(); //パスワード（確認用）

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LinkAnonymousUserModel>(
        create: (_) => LinkAnonymousUserModel(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("ユーザー登録"),
          ),
          body: Consumer<LinkAnonymousUserModel>(
            builder: (context, model, child) {
              return Stack(children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //メールアドレス
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
                              model.startLoading();
                              try {
                                await model.linkAnonymousUser();
                                await model.login();
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('ユーザー登録が完了しました'),
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
                                Navigator.of(context).pop();
                              } catch (e) {
                                _showTextDialog(context, e.toString());
                                model.endLoading();
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
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox()
              ]);
            },
          ),
        ));
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
