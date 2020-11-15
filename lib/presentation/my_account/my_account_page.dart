import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_page.dart';
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            title: Text(
              'メニュー',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Consumer<MyAccountModel>(
          builder: (context, model, child) {
            return Stack(
              children: <Widget>[
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // 右スワイプ
                    if (details.delta.dx > 20) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          model.mail == null
                              ? Text('ゲスト')
                              : Text('${model.mail}'),
                          model.mail == null
                              ? FlatButton(
                                  textColor: Color(0xFFF39800),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LinkAnonymousUserPage(),
                                      ),
                                    );
                                    await model.fetchMyAccount();
                                  },
                                  child: Text('登録して利用する'),
                                )
                              : SizedBox(),
                          model.mail != null
                              ? FlatButton(
                                  textColor: Color(0xFFF39800),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmailUpdatePage(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Text('メールアドレスの変更'),
                                )
                              : SizedBox(),
                          model.mail != null
                              ? FlatButton(
                                  textColor: Color(0xFFF39800),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PasswordUpdatePage(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Text('パスワードの変更'),
                                )
                              : SizedBox(),
                          model.mail != null
                              ? FlatButton(
                                  textColor: Color(0xFFF39800),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactPage(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Text('お問い合わせ'),
                                )
                              : SizedBox(),
                          model.mail != null
                              ? FlatButton(
                                  textColor: Colors.grey,
                                  onPressed: () async {
                                    await model.signOut();
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInPage(),
                                      ),
                                    );
                                  },
                                  child: Text('ログアウト'),
                                )
                              : SizedBox(),
                        ],
                      ),
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
