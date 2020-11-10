import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/presentation/email_update/email_update_model.dart';
import 'package:recipe/presentation/my_account/my_account_page.dart';

class EmailUpdatePage extends StatelessWidget {
  final mailController = TextEditingController();
  final confirmMailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmailUpdateModel>(
      create: (_) => EmailUpdateModel(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text(
              'メールアドレスの変更',
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
        body: Consumer<EmailUpdateModel>(
          builder: (context, model, child) {
            return Stack(
              children: <Widget>[
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
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: confirmMailController,
                        onChanged: (text) {
                          model.changeConfirmMail(text);
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'メールアドレス（確認用）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
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
                          child: Text('メールアドレスを変更'),
                          color: Color(0xFFF39800),
                          textColor: Colors.white,
                          onPressed: model.isMailValid &&
                                  model.isConfirmMailValid &&
                                  model.isPasswordValid
                              ? () async {
                                  model.startLoading();
                                  try {
                                    await model.updateMail(context);
                                    await showTextDialog(
                                        context, 'メールアドレスを変更しました');
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyAccountPage(),
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
