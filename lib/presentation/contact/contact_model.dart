import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/contact.dart';

class ContactModel extends ChangeNotifier {
  String contactTitle = '';

  Future contactToFirebase() async {
    if (contactTitle.isEmpty){
      throw('タイトルを入力してください');
    }
    FirebaseFirestore.instance.collection('contacts').add({
      'title':contactTitle,
    });
    print('AAAAA');
  }
}
