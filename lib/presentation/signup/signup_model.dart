import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';

class SignUpModel extends ChangeNotifier {
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
  UserCredential userCredential;

  Future signUp() async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }

    /// 入力されたメール, パスワードで UserCredential を作成
    try {
      this.userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: this.mail,
        password: this.password,
      );
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    /// UserCredential の null チェック
    if (this.userCredential == null) {
      throw ('エラーが発生しました。');
    }

    /// users コレクションにユーザーデータを保存
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(this.userCredential.user.uid)
          .set(
        {
          'email': this.mail,
          'userId': this.userCredential.user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw ('エラーが発生しました。');
    }
  }

  Future signInAnonymously() async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInAnonymously();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user.uid)
          .set(
        {
          'email': null,
          'userId': result.user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw ('エラーが発生しました。');
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
