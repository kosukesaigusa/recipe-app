import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/my_account/my_account_page.dart';
import 'package:recipe/presentation/password_update/password_update_model.dart';

class PasswordUpdatePage extends StatelessWidget {
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); //パスワード（確認用）

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasswordUpdateModel>(
      create: (_) => PasswordUpdateModel()..fetchPasswordUpdate(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("パスワードの変更"),
        ),
        body: Consumer<PasswordUpdateModel>(
          builder: (context, model, child) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //メールアドレス
                    TextFormField(
                      controller: passwordController,
                      onChanged: (text) {
                        model.newPassword = text;
                      },
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '現在のパスワード',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //パスワード
                    TextFormField(
                      controller: newPasswordController,
                      onChanged: (text) {
                        model.password = text;
                      },
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '新しいパスワード',
                        // errorText: '８文字以上20文字以内',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      onChanged: (text) {
                        model.confirm = text;
                      },
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '新しいパスワード（確認用）',
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
                        child: Text('パスワードの変更'),
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () async {
                          try {
                            await model.signUp();
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyAccountPage(),
                              ),
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
