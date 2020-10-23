import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeAddModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Recipe> recipes = [];
  String userId = '';
  Timestamp createdAt;
  Timestamp updatedAt;
  String name = '';
  String thumbnailURL = '';
  String imageURL = '';
  String content = '';
  List ingredients;
  String reference = '';
  Map tokenMap;
  bool isPublic = false;
  bool isAccept = false;

  Future fetchRecipeAdd(context) async {
    final docs =
        await FirebaseFirestore.instance.collection('recipes').getDocuments();
    final recipes = docs.documents.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;
    notifyListeners();
  }

  Future addRecipeToFirebase() async {
    if (name.isEmpty) {
      throw ('レシピ名を入力してください');
    }
    if (content.isEmpty) {
      throw ('作り方・材料を入力してください');
    }

    FirebaseFirestore.instance.collection('recipes').add(
      {
        'name': name,
        'imageURL': imageURL,
        'thumbnailURL': thumbnailURL,
        'content': content,
        'reference': reference,
        'createdAt': Timestamp.now(),
        'updateAt': Timestamp.now(),
        'isPublic': isPublic,
        'isAccept': isAccept,
        'userId': _auth.currentUser.uid,
      },
    );
  }
}
