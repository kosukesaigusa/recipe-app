import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User() {
    this.createdAt = null;
    this.email = '';
    this.displayName = '';
    this.userId = '';
    this.iconName = '';
    this.iconURL = '';
  }

  Timestamp createdAt;
  String email;
  String displayName;
  String userId;
  String iconName;
  String iconURL;
}
