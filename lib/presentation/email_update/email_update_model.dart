import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class EmailUpdateModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String mail;
  String confirmMail = '';
  String password = '';
  String errorMail = '';
  String errorConfirmMail = '';
  String errorPassword = '';
  bool isLoading = false;
  bool isMailValid = false;
  bool isConfirmMailValid = false;
  bool isPasswordValid = false;

  Future<void> updateMail(context) async {
    if (mail != confirmMail) {
      throw ("メールアドレスが一致しません。");
    }

    /// 現在のユーザーを取得
    User user = _auth.currentUser;

    if (user == null) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
    }

    /// 現在のユーザーの Email, Password で再認証を行う
    try {
      EmailAuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: user.email,
        password: this.password,
      );
      await user.reauthenticateWithCredential(emailAuthCredential);
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    /// メールアドレスの更新
    try {
      await user.updateEmail(this.mail);
      await user.sendEmailVerification();
      DocumentReference targetDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await targetDoc.update({
        'email': this.mail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  void changeMail(text) {
    this.mail = text.trim();
    if (text.length == 0) {
      this.isMailValid = false;
      this.errorMail = 'メールアドレスを入力して下さい。';
    } else {
      this.isMailValid = true;
      this.errorMail = '';
    }
    notifyListeners();
  }

  void changeConfirmMail(text) {
    this.confirmMail = text.trim();
    if (text.length == 0) {
      isConfirmMailValid = false;
      this.errorConfirmMail = 'メールアドレスを再入力して下さい。';
    } else {
      isConfirmMailValid = true;
      this.errorConfirmMail = '';
    }
    notifyListeners();
  }

  void changePassword(text) {
    this.password = text;
    if (text.length == 0) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isPasswordValid = true;
      this.errorPassword = '';
    }
    notifyListeners();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
