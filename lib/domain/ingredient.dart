import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  Ingredient(DocumentSnapshot doc) {
    createdAt = doc.data()['createdAt'];
    name = doc.data()['name'];
  }

  Timestamp createdAt;
  String name;
}
