import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeModel extends ChangeNotifier {
  bool isLoading = true;
  final String userId;
  final String documentId;
  String name = "";
  String imageURL = "";
  String content = "";
  String createdAt = "";
  bool isPublice = false;
  bool isMyRecipe;
  Recipe recipe = null;
  RecipeModel(this.userId, this.documentId){
    isMyRecipe = userId == documentId;
    this.fetchRecipe();
  }

  Future fetchRecipe() async {
    startLoading();
    DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('public_recipes')
      .doc(documentId)
      .get();

    recipe = await Recipe(doc);
    name = recipe.name;
    imageURL = recipe.imageURL;
    content = recipe.content;
    createdAt = recipe.createdAt.toString();
    isPublice = recipe.isPublic;

    endLoading();
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
  }

  void endLoading() {
    this.isLoading = false;
  }
}
