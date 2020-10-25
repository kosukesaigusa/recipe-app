import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/will_pop_scope.dart';
import 'package:recipe/presentation/email_update/email_update_page.dart';
import 'package:recipe/presentation/link_anonymous_user/link_anonymous_user_page.dart';
import 'package:recipe/presentation/my_account/my_account_model.dart';
import 'package:recipe/presentation/password_update/password_update_page.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class MyAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<MyAccountModel>(
        create: (_) => MyAccountModel()..fetchMyAccount(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0, // 影を消す
            ),
          ),
          body: Consumer<MyAccountModel>(builder: (context, model, child) {
            return Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('仮設置：戻るボタン'),
                        ),
                        model.mail == null
                            ? Text('ゲスト')
                            : Text('${model.mail}'),
                        model.mail == null
                            ? FlatButton(
                                textColor: Colors.blue,
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
                                textColor: Colors.blue,
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
                                textColor: Colors.blue,
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
                                textColor: Colors.grey,
                                onPressed: () {
                                  Navigator.pushReplacement(
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
      ),
    );
  }
}
