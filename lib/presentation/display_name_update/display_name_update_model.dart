import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';

class DisplayNameUpdateModel extends ChangeNotifier {
  FirebaseAuth auth;
  String userId;
  String originalDisplayName;
  String newDisplayName;
  String errorDisplayName;
  bool isDisplayNameValid;
  bool isLoading;
  bool isFocused;

  DisplayNameUpdateModel() {
    this.auth = FirebaseAuth.instance;
    this.userId = '';
    this.originalDisplayName = '';
    this.newDisplayName = '';
    this.errorDisplayName = '';
    this.isDisplayNameValid = false;
    this.isLoading = false;
    this.isFocused = true;
    init();
  }

  Future<void> init() async {
    this.userId = this.auth.currentUser.uid;
    DocumentSnapshot _userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('${this.userId}')
        .get();
    this.originalDisplayName = _userDoc.data()['displayName'];
  }

  Future<void> updateDisplayName(context) async {
    if (this.originalDisplayName == this.newDisplayName) {
      throw ('表示名が変更されていません。');
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${this.userId}')
          .update(
        {
          'displayName': this.newDisplayName,
        },
      );
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  void changeDisplayName(text) {
    this.newDisplayName = text;
    if (text.isEmpty) {
      this.isDisplayNameValid = false;
      this.errorDisplayName = '新しい表示名を入力して下さい。';
    } else if (text.length > 20) {
      this.isDisplayNameValid = false;
      this.errorDisplayName = '20文字以内で入力して下さい。';
    } else {
      this.isDisplayNameValid = true;
      this.errorDisplayName = '';
    }
    notifyListeners();
  }

  void changeFocus(val) {
    this.isFocused = val;
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
