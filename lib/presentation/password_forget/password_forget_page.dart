import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/common/will_pop_scope.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

import 'password_forget_model.dart';

class ForgetPasswordPage extends StatelessWidget {
  final mailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<ForgetPasswordModel>(
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
                          TextFormField(
                            controller: mailController,
                            onChanged: (text) {
                              model.changeMail(text);
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              errorText: model.errorMail == ''
                                  ? null
                                  : model.errorMail,
                              labelText: 'メールアドレス',
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
                              child: Text('再設定する'),
                              color: Color(0xFFF39800),
                              textColor: Colors.white,
                              onPressed: model.isMailValid
                                  ? () async {
                                      model.startLoading();
                                      try {
                                        await model.sendResetEmail();
                                        await showTextDialog(context,
                                            'パスワードの再設定用のメールを送信しました。メールボックスをご確認下さい。');
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignInPage(),
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
                          FlatButton(
                            child: Text(
                              'ログイン画面に戻る',
                            ),
                            textColor: Color(0xFFF39800),
                            onPressed: () {
                              Navigator.pushReplacement(
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
      ),
    );
  }
}
