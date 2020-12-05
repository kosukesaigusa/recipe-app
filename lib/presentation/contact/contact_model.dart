import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactModel extends ChangeNotifier {
  bool isLoading = false;
  String mail = '';
  String category = '';
  String content = '';
  bool isCategoryValid = false;
  bool isContentValid = false;
  String errorCategory = '';
  String errorContent = '';

  Future fetchContact() async {
    startLoading();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    endLoading();
    notifyListeners();
  }

  Future<void> submitForm() async {
    try {
      await FirebaseFirestore.instance.collection('contacts').add({
        'userId': FirebaseAuth.instance.currentUser.uid,
        'email': this.mail,
        'category': this.category,
        'content': this.content,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('お問い合わせの送信時にエラー');
      throw ('エラーが発生しました');
    }
  }

  void changeCategory(text) {
    this.category = text;
    if (text.isEmpty) {
      this.isCategoryValid = false;
      this.errorCategory = 'お問い合わせカテゴリーを選択してください。';
    } else {
      this.isCategoryValid = true;
      this.errorCategory = '';
    }
    notifyListeners();
  }

  changeContent(text) {
    this.content = text;
    if (text.isEmpty) {
      this.isContentValid = false;
      this.errorContent = 'お問い合わせの内容を入力して下さい。';
    } else if (text.length > 300) {
      this.isContentValid = false;
      this.errorContent = '300文字以内で入力して下さい。';
    } else {
      this.isContentValid = true;
      this.errorContent = '';
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
