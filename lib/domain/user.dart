import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User() {
    this.createdAt = null;
    this.email = '';
    this.displayName = '';
    this.userId = '';
    this.iconName = '';
    this.iconURL = '';
    this.recipeCount = 0;
    this.publicRecipeCount = 0;
  }

  Timestamp createdAt;
  String email;
  String displayName;
  String userId;
  String iconName;
  String iconURL;
  int recipeCount;
  int publicRecipeCount;
}
