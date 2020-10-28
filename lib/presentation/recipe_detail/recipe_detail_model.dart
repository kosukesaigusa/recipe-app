import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeDetailModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  String userId;
  String recipeDocumentId;
  String recipeOwnerId;
  String name = "";
  String content = "";
  bool isMyRecipe;
  Recipe recipe;


  RecipeDetailModel(Recipe recipe) {
    this.recipeDocumentId = recipe.documentId;
    this.recipeOwnerId = recipe.userId;
    this.userId = _auth.currentUser.uid;
    this.isMyRecipe = recipeOwnerId == this.userId;
    this.content = recipe.content;
    this.name = recipe.name;
    endLoading();
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
