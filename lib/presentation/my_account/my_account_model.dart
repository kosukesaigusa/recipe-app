import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountModel extends ChangeNotifier {
  bool isLoading = false;
  String mail;
  User user;
//Authからアドレス取得
  Future fetchMyAccount() async {
    this.isLoading = true;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    this.isLoading = false;
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
