import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/signin/signin_page.dart';
import 'forget_password_model.dart';

class ForgetPasswordPage extends StatelessWidget {
  final mailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgetPasswordModel>(
      create: (_) => ForgetPasswordModel(),
      child: Scaffold(
        body: Consumer<ForgetPasswordModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
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
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            child: Text('再設定する'),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () async {
                              model.startLoading();
                              try {
                                await model.sendResetEmail();
                                await _showTextDialog(context, '再設定メールを送信しました');
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
                        FlatButton(
                          child: Text(
                            'ログイン画面に戻る',
                          ),
                          textColor: Colors.blue,
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          },
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
              ],
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
