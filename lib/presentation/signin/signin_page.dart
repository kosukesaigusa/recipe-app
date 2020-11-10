import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/common/will_pop_scope.dart';
import 'package:recipe/presentation/password_forget/password_forget_page.dart';
import 'package:recipe/presentation/signin/signin_model.dart';
import 'package:recipe/presentation/signup/signup_page.dart';
import 'package:recipe/presentation/top/top_page.dart';

class SignInPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        child: Scaffold(
          body: Consumer<SignInModel>(
            builder: (context, model, child) {
              return Stack(
                children: [
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
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            child: Text('ログイン'),
                            color: Color(0xFFF39800),
                            textColor: Colors.white,
                            onPressed:
                                model.isMailValid && model.isPasswordValid
                                    ? () async {
                                        model.startLoading();
                                        try {
                                          await model.login();
                                          await Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TopPage(),
                                            ),
                                          );
                                        } catch (e) {
                                          showTextDialog(context, e.toString());
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
                            '新規登録はこちら',
                          ),
                          textColor: Color(0xFFF39800),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'パスワードを忘れた場合',
                          ),
                          textColor: Colors.grey,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPasswordPage(),
                              ),
                            );
                          },
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
                      : SizedBox(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
