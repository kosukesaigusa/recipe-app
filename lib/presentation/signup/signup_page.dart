import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/signin/signin_page.dart';
import 'package:recipe/presentation/signup/signup_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class SignUpPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpModel>(
        create: (_) => SignUpModel(),
        // ..fetchSignUp(context),
        child: Scaffold(
          body: Consumer<SignUpModel>(
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
                        controller: passwordController,
                        onChanged: (text) {
                          model.password = text;
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
                          child: Text('新規登録'),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              await model.signUp();
                            } catch (e) {
                              _showTextDialog(context, e.toString());
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FlatButton(
                        child: Text(
                          'ログインはこちら',
                        ),
                        textColor: Colors.blue,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInPage(),
                            ),
                          );
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'ゲストとして利用',
                        ),
                        textColor: Colors.grey,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
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
