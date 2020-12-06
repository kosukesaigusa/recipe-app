import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';

class LinkAnonymousUserModel extends ChangeNotifier {
  String mail = '';
  String password = '';
  String confirm = '';
  String errorMail = '';
  String errorPassword = '';
  String errorConfirm = '';
  bool isLoading = false;
  bool isMailValid = false;
  bool isPasswordValid = false;
  bool isConfirmValid = false;

  Future linkAnonymousUser() async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: this.mail,
      password: this.password,
    );

    User anonymousUser = FirebaseAuth.instance.currentUser;

    try {
      await anonymousUser.linkWithCredential(credential);
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(anonymousUser.uid)
          .collection('user_info')
          .doc('email')
          .update(
        {
          'email': this.mail,
        },
      );
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  /// ログイン（ユーザー登録直後に叩く）
  Future login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: this.mail,
        password: this.password,
      );
    } catch (e) {
      print('${e.code}: $e');
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

  void changeConfirm(text) {
    this.confirm = text;
    if (text.length == 0) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードを再入力して下さい。';
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
