import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class PasswordUpdateModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String password = '';
  String newPassword = '';
  String confirm = '';
  String errorPassword = '';
  String errorNewPassword = '';
  String errorConfirm = '';
  bool isLoading = false;
  bool isPasswordValid = false;
  bool isNewPasswordValid = false;
  bool isConfirmValid = false;

  Future updatePassword(context) async {
    if (this.newPassword != this.confirm) {
      throw ('パスワードが一致しません。');
    } else if (this.password == this.newPassword) {
      throw ('パスワードが変更されていません。');
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

    /// パスワードの更新
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  void changePassword(text) {
    this.password = text;
    if (text.length == 0) {
      isPasswordValid = false;
      this.errorPassword = '現在のパスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isPasswordValid = true;
      this.errorPassword = '';
    }
    notifyListeners();
  }

  void changeNewPassword(text) {
    this.newPassword = text;
    if (text.length == 0) {
      isNewPasswordValid = false;
      this.errorNewPassword = '新しいパスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isNewPasswordValid = false;
      this.errorNewPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isNewPasswordValid = true;
      this.errorNewPassword = '';
    }
    notifyListeners();
  }

  void changeConfirm(text) {
    this.confirm = text;
    if (text.length == 0) {
      isConfirmValid = false;
      this.errorConfirm = '新しいパスワードを再入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードは8文字以上20文字以内です。';
    } else {
      isConfirmValid = true;
      this.errorConfirm = '';
    }
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}
