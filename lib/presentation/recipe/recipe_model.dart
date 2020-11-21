import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeModel extends ChangeNotifier {
  RecipeModel(_recipe) {
    this.recipe = _recipe;
    this.userId = FirebaseAuth.instance.currentUser.uid;
    this.isLoading = false;
    fetchRecipe();
  }

  Recipe recipe;
  String userId;
  bool isLoading;
  bool isFavorite = false;

  final currentUserId = FirebaseAuth.instance.currentUser.uid;

  Future<void> fetchRecipe() async {
    startLoading();
    bool _isMyRecipe = this.recipe.userId == this.userId;
    if (_isMyRecipe) {
      /// レシピのドキュメント ID が "public_" から始まる場合は、
      /// それに対応する「わたしのレシピ」を取得して
      /// recipe インスタンスを上書きする
      if (this.recipe.documentId.startsWith('public_')) {
        DocumentSnapshot _doc = await FirebaseFirestore.instance
            .collection('users/${this.userId}/recipes')
            .doc(this.recipe.documentId.replaceFirst('public_', ''))
            .get();
        this.recipe = Recipe(_doc);
      } else {
        // 何もしない
      }
    } else {
      // 何もしない
    }

    // 自分のレシピかどうかの情報をレシピインスタンスに格納
    this.recipe.isMyRecipe = _isMyRecipe;

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

  Future<void> pressedFavoriteButton() async {
    if (isFavorite) {
      isFavorite = false;
      notifyListeners();
      // お気に入りから削除する
      await FirebaseFirestore.instance
          .collection('users/$currentUserId/favorite_recipes')
          .doc(recipe.documentId)
          .delete();
    } else {
      isFavorite = true;
      notifyListeners();
      // お気に入りに追加する
      // ひとまずdocumentIDを追加していく形で実装します
      await FirebaseFirestore.instance
          .collection('users/$currentUserId/favorite_recipes')
          .doc(recipe.documentId)
          .set(
        {
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    }
  }
}
