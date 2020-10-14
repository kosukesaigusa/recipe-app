import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountModel extends ChangeNotifier {
  bool isLoading = false;
  String mail;
  User user;

  Future fetchMyAccount() async {
    this.isLoading = true;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    this.user = await fetchUser();
    this.isLoading = false;
    notifyListeners();
  }

  Future<User> fetchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!doc.exists) {
      return null;
    }
    return user;
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
