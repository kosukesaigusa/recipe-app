import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/email_update/email_update_model.dart';

class EmailUpdatePage extends StatelessWidget {
  final mailController = TextEditingController();
  final confirmMailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmailUpdateModel>(
      create: (_) => EmailUpdateModel(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('メールアドレスの更新'),
        ),
        body: Consumer<EmailUpdateModel>(
          builder: (context, model, child) {
            return Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                        ),
                        //メールアドレス
                        TextFormField(
                          controller: mailController,
                          onChanged: (text) {
                            model.newMail = text.trim();
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
                        //メールアドレス(確認用)
                        TextFormField(
                          controller: confirmMailController,
                          onChanged: (text) {
                            model.confirmMail = text.trim();
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'メールアドレス(確認用)',
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
                            child: Text('メールアドレスの更新'),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () async {
                              model.startLoading();
                              try {
                                await model.updateMail();
                                await _showTextDialog(
                                    context, 'メールアドレスの変更をしました');
                                Navigator.of(context).pop();
                              } catch (e) {
                                _showTextDialog(context, e.toString());
                              }
                              model.endLoading();
                            },
                          ),
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
                    : SizedBox(),
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
