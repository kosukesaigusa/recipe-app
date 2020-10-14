import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // User(this.createdAt, this.email, this.userId);
  User(DocumentSnapshot doc) {
    userId = doc.id;
    email = doc.data()['email'];
    createdAt = doc.data()['createdAt'];
  }
  Timestamp createdAt;
  String email;
  String userId;
}
