import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/presentation/top/top_page.dart';

import 'link_anonymous_user_model.dart';

class LinkAnonymousUserPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: mailController,
                        onChanged: (text) {
                          model.changeMail(text);
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          errorText:
                              model.errorMail == '' ? null : model.errorMail,
                          labelText: 'メールアドレス',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordController,
                        onChanged: (text) {
                          model.changePassword(text);
                        },
                        obscureText: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                          errorText: model.errorPassword == ''
                              ? null
                              : model.errorPassword,
                          labelText: 'パスワード',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: confirmController,
                        onChanged: (text) {
                          model.changeConfirm(text);
                        },
                        obscureText: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'パスワード（確認用）',
                          errorText: model.errorConfirm == ''
                              ? null
                              : model.errorConfirm,
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
                              await showTextDialog(context, 'ユーザー登録が完了しました。');
                              await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopPage(),
                                ),
                              );
                            } catch (e) {
                              showTextDialog(context, e);
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
