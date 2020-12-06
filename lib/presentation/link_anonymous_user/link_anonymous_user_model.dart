import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';

class LinkAnonymousUserModel extends ChangeNotifier {
  LinkAnonymousUserModel() {
    this.anonymousUser = FirebaseAuth.instance.currentUser;
    this.mail = '';
    this.password = '';
    this.confirm = '';
    this.errorMail = '';
    this.errorPassword = '';
    this.errorConfirm = '';
    this.isLoading = false;
    this.isMailValid = false;
    this.isPasswordValid = false;
    this.isConfirmValid = false;
  }

  User anonymousUser;
  String mail;
  String password;
  String confirm;
  String errorMail;
  String errorPassword;
  String errorConfirm;
  bool isLoading;
  bool isMailValid;
  bool isPasswordValid;
  bool isConfirmValid;

  Future<void> linkAnonymousUser() async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: this.mail,
      password: this.password,
    );

    try {
      await this.anonymousUser.linkWithCredential(credential);
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      WriteBatch _batch = _firestore.batch();
      DocumentReference _userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(this.anonymousUser.uid);

      DocumentReference _userEmailDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(this.anonymousUser.uid)
          .collection('user_info')
          .doc('email');

      _batch.update(_userDoc, {'displayName': 'シンプルなレシピユーザー'});
      _batch.set(_userEmailDoc, {'email': this.mail});
      await _batch.commit();
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw ('エラーが発生しました');
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
