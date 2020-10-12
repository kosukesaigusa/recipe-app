import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountModel extends ChangeNotifier {
  bool isLoading = false;
  String mail = '';

  Future fetchMyAccount() async {
    // ここにユーザーのメールアドレスを取得する処理を書く
    // ...
    // ...
    // this.mail = ユーザーのメールアドレス
    notifyListeners();
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('${e.code}: $e');
      throw ('エラーが発生しました');
    }
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
