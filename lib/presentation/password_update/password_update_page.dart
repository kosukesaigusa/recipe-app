import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/presentation/password_update/password_update_model.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class PasswordUpdatePage extends StatelessWidget {
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasswordUpdateModel>(
      create: (_) => PasswordUpdateModel(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text(
              "パスワードの変更",
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
        body: Consumer<PasswordUpdateModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                          labelText: '現在のパスワード',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        onChanged: (text) {
                          model.changeNewPassword(text);
                        },
                        obscureText: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                          errorText: model.errorNewPassword == ''
                              ? null
                              : model.errorNewPassword,
                          labelText: '新しいパスワード',
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
                          child: Text('パスワードの変更'),
                          color: Color(0xFFF39800),
                          textColor: Colors.white,
                          onPressed: model.isPasswordValid &&
                                  model.isNewPasswordValid &&
                                  model.isConfirmValid
                              ? () async {
                                  model.startLoading();
                                  try {
                                    await model.updatePassword(context);
                                    await model.signOut();
                                    model.endLoading();
                                    await showTextDialog(context,
                                        'パスワードを変更しました。新しいパスワードで再度ログインして下さい。');
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
    );
  }
}
