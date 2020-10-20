import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/email_update/email_update_page.dart';
import 'package:recipe/presentation/link_anonymous_user/link_anonymous_user_page.dart';
import 'package:recipe/presentation/my_account/my_account_model.dart';
import 'package:recipe/presentation/password_update/password_update_page.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class MyAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAccountModel>(
      create: (_) => MyAccountModel()..fetchMyAccount(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("マイページ"),
        ),
        body: Consumer<MyAccountModel>(builder: (context, model, child) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      //ここにアドレス

                      padding: EdgeInsets.only(top: 30),

                      height: 100,
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Text('メールアドレス'),
                          SizedBox(
                            height: 10,
                          ),
                          model.mail == null
                              ? Text(
                                  'ゲスト',
                                  style: TextStyle(fontSize: 20),
                                )
                              : Text(
                                  '${model.mail}',
                                  style: TextStyle(fontSize: 20),
                                ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      color: Colors.black,
                    ),
                    Container(
                      //ここにリストで並べる
                      height: 300,
                      width: double.infinity,
                      child: ListView(
                        children: <Widget>[
                          //TODO:ゲストユーザーのみ表示の三項演算子を書く
                          ListTile(
                              title: Center(
                                child: Text(
                                  '登録して利用する',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LinkAnonymousUserPage(),
                                  ),
                                );
                              }),
                          Divider(
                            height: 20,
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                'Emailの変更',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailUpdatePage(),
                                    fullscreenDialog: true,
                                  ));
                            },
                          ),
                          Divider(
                            height: 20,
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                'パスワードの変更',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PasswordUpdatePage(),
                                    fullscreenDialog: true,
                                  ));
                            },
                          ),
                          Divider(
                            height: 20,
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                'ログアウト',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            onTap: () async {
                              model.startLoading();
                              try {
                                await model.signOut();
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInPage(),
                                  ),
                                );
                              } catch (e) {
                                await _showErrorDialog(context, e);
                                model.endLoading();
                              }
                            },
                          ),
                          Divider(
                            height: 20,
                          ),
                        ],
                      ),
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
            ],
          );
        }),
      ),
    );
  }

  Future _showErrorDialog(BuildContext context, dynamic e) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(e.toString()),
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
}
