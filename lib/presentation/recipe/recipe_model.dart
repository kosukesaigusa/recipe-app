import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeModel extends ChangeNotifier {
  RecipeModel(_recipe) {
    this.recipe = _recipe;
    this.userId = FirebaseAuth.instance.currentUser.uid;
    this.authorIconURL = '';
    this.authorDisplayName = '';
    this.isLoading = false;
    fetchRecipe();
  }

  Recipe recipe;
  String userId;
  String authorIconURL;
  String authorDisplayName;
  bool isLoading;

  Future<void> fetchRecipe() async {
    startLoading();
    bool _isMyRecipe = this.recipe.userId == this.userId;
    if (_isMyRecipe) {
      /// レシピのドキュメント ID が "public_" から始まる場合は、
      /// それに対応する「わたしのレシピ」を取得して
      /// recipe インスタンスを上書きする
      if (this.recipe.documentId.startsWith('public_')) {
        DocumentSnapshot _recipeDoc = await FirebaseFirestore.instance
            .collection('users/${this.userId}/recipes')
            .doc(this.recipe.documentId.replaceFirst('public_', ''))
            .get();
        this.recipe = Recipe(_recipeDoc);
      } else {
        // 何もしない
      }
    } else {
      // 何もしない
    }

    // 自分のレシピかどうかの情報をレシピインスタンスに格納
    this.recipe.isMyRecipe = _isMyRecipe;

    // レシピ作者のアイコンと表示名を取得
    DocumentSnapshot _userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.recipe.userId)
        .get();
    this.authorIconURL = _userDoc.data()['iconURL'];
    this.authorDisplayName = _userDoc.data()['displayName'];

    endLoading();
    notifyListeners();
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
