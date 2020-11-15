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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(36.0),
            child: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              centerTitle: true,
              title: Text(
                "ユーザー登録",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
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
                        height: 16,
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
                        height: 16,
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
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          child: Text('ユーザー登録する'),
                          color: Color(0xFFF39800),
                          textColor: Colors.white,
                          onPressed: model.isMailValid &&
                                  model.isPasswordValid &&
                                  model.isConfirmValid
                              ? () async {
                                  model.startLoading();
                                  try {
                                    await model.linkAnonymousUser();
                                    await model.login();
                                    await showTextDialog(
                                        context, 'ユーザー登録が完了しました。');
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
                                }
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: 16,
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
