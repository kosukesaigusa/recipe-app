import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:recipe/common/convert_error_message.dart';

class MyAccountModel extends ChangeNotifier {
  bool isLoading;
  String mail;
  PackageInfo packageInfo;
  String version;

  MyAccountModel() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    this.isLoading = true;
    this.version = '';
    init();
    notifyListeners();
  }

  Future init() async {
    startLoading();
    this.packageInfo = await PackageInfo.fromPlatform();
    this.version = packageInfo.version;
    notifyListeners();
    endLoading();
  }

  Future fetchMyAccount() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('${e.code}: $e');
      throw (convertErrorMessage(e.code));
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
