import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class SearchModel extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = '';
  bool isLoading;
  int recipeTabIndex = 0;
  List recipes = [];

  Future fetchSearch(context) async {
    startLoading();

    if (auth == null) {
      // ユーザーが見つからない場合は pushReplacement() でログインページへ
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
    } else {
      this.userId = auth.currentUser.uid;
    }

    // 自身のレシピを10件取得
    QuerySnapshot docsRecipe = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('createdAt')
        .limit(10)
        .get();

    // レシピをリストとして格納
    final recipes = docsRecipe.docs.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;

    endLoading();
    notifyListeners();
  }

  void onRecipeTabTapped(int index) {
    this.recipeTabIndex = index;
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
  }

  void endLoading() {
    this.isLoading = false;
  }
}
