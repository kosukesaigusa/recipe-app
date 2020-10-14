import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User(this.createdAt, this.email, this.userId);
//
  Timestamp createdAt;
  String email;
  String userId;
}
