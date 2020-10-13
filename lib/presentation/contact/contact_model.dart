import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactModel extends ChangeNotifier {
  String email = '';
  String category = '';
  String content = '';

  // Timestamp createAt;

  Future addContactToFirebase() async {
    if (email.isEmpty) {
      throw ('emailを入力してください');
    }
    if (category.isEmpty) {
      throw ('タイトルを入力してください');
    }
    if (content.isEmpty) {
      throw ('本文を入力してください');
    }
    FirebaseFirestore.instance.collection('contacts').add({
      'email': email,
      'category': category,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }
}
