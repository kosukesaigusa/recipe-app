import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class SearchModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = '';
  bool isLoading;
  List myRecipes = [];
  List publicRecipes = [];
  int loadLimit = 10;
  QueryDocumentSnapshot myLastVisible;
  QueryDocumentSnapshot publicLastVisible;
  bool isMyRecipeLeft = true;
  bool isPublicRecipeLeft = true;
  bool noMyRecipe = false;
  bool noPublicRecipe = false;

  Future fetchRecipes(context) async {
    startLoading();

    if (_auth.currentUser == null) {
      // ユーザーが見つからない場合は pushReplacement() でログインページへ
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
    } else {
      this.userId = _auth.currentUser.uid;
    }

    /// わたしのレシピ
    // わたしのレシピを10件取得
    QuerySnapshot docsMyRecipe = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('createdAt', descending: true)
        .limit(this.loadLimit)
        .get();

    // 取得するレシピが1件以上あるか確認する
    if (docsMyRecipe.docs.length == 0) {
      // 1件もなければ、「まだレシピが登録されていません」と表示する
      this.isMyRecipeLeft = false;
      this.noMyRecipe = true;
    } else if (docsMyRecipe.docs.length < this.loadLimit) {
      // 1件以上あれば、新たに取得した最後の要素を更新する
      this.myLastVisible = docsMyRecipe.docs[docsMyRecipe.docs.length - 1];
      // 1件以上あれば、それをわたしのレシピをリストとして格納
      final myRecipes = docsMyRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes = myRecipes;
      this.isMyRecipeLeft = false;
    } else {
      // 1件以上あれば、新たに取得した最後の要素を更新する
      this.myLastVisible = docsMyRecipe.docs[docsMyRecipe.docs.length - 1];
      // 1件以上あれば、それをわたしのレシピをリストとして格納
      final myRecipes = docsMyRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes = myRecipes;
    }

    /// みんなのレシピ
    // みんなのレシピを10件取得
    QuerySnapshot docsPublicRecipe = await FirebaseFirestore.instance
        .collection('public_recipes')
        .orderBy('createdAt', descending: true)
        .limit(this.loadLimit)
        .get();

    // 取得するレシピが1件以上あるか確認する
    if (docsPublicRecipe.docs.length == 0) {
      // 1件もなければ、「まだレシピが登録されていません」と表示する
      this.isPublicRecipeLeft = false;
      this.noPublicRecipe = true;
    } else if (docsPublicRecipe.docs.length < this.loadLimit) {
      // 1件以上あれば、新たに取得した最後の要素を更新する
      this.publicLastVisible =
          docsPublicRecipe.docs[docsPublicRecipe.docs.length - 1];
      // 1件以上あれば、それをみんなのレシピをリストとして格納
      final publicRecipes =
          docsPublicRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes = publicRecipes;
      this.isPublicRecipeLeft = false;
    } else {
      // 1件以上あれば、新たに取得した最後の要素を更新する
      this.publicLastVisible =
          docsPublicRecipe.docs[docsPublicRecipe.docs.length - 1];
      // 1件以上あれば、それをみんなのレシピをリストとして格納
      final publicRecipes =
          docsPublicRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes = publicRecipes;
    }

    endLoading();
    notifyListeners();
  }

  /// わたしのレシピをさらに10件取得
  Future fetchMoreMyRecipes() async {
    QuerySnapshot docsMyRecipe = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(this.myLastVisible)
        .limit(this.loadLimit)
        .get();

    // 新たに取得するレシピが残っているか確認する
    if (docsMyRecipe.docs.length == 0) {
      // 残っていなければ、「更に読み込む」の表示を「以上です」に変える
      this.isMyRecipeLeft = false;
    } else if (docsMyRecipe.docs.length < this.loadLimit) {
      // 残っていれば、新たに取得した最後の要素を更新する
      this.myLastVisible = docsMyRecipe.docs[docsMyRecipe.docs.length - 1];
      // 新たに取得したレシピを、既存のレシピのリストに連結する
      final myRecipes = docsMyRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes.addAll(myRecipes);
      this.isMyRecipeLeft = false;
    } else {
      // 残っていれば、新たに取得した最後の要素を更新する
      this.myLastVisible = docsMyRecipe.docs[docsMyRecipe.docs.length - 1];
      // 新たに取得したレシピを、既存のレシピのリストに連結する
      final myRecipes = docsMyRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes.addAll(myRecipes);
    }

    notifyListeners();
  }

  /// みんなのレシピをさらに10件取得
  Future fetchMorePublicRecipes() async {
    QuerySnapshot docsPublicRecipe = await FirebaseFirestore.instance
        .collection('public_recipes')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(this.publicLastVisible)
        .limit(this.loadLimit)
        .get();

    // 新たに取得するレシピが残っているか確認する
    if (docsPublicRecipe.docs.length == 0) {
      // 残っていなければ、「更に読み込む」の表示を「以上です」に変える
      this.isPublicRecipeLeft = false;
    } else if (docsPublicRecipe.docs.length < this.loadLimit) {
      // 残っていれば、新たに取得した最後の要素を更新する
      this.publicLastVisible =
          docsPublicRecipe.docs[docsPublicRecipe.docs.length - 1];
      // 新たに取得したレシピを、既存のレシピのリストに連結する
      final publicRecipes =
          docsPublicRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes.addAll(publicRecipes);
      this.isPublicRecipeLeft = false;
    } else {
      // 残っていれば、新たに取得した最後の要素を更新する
      this.publicLastVisible =
          docsPublicRecipe.docs[docsPublicRecipe.docs.length - 1];
      // 新たに取得したレシピを、既存のレシピのリストに連結する
      final publicRecipes =
          docsPublicRecipe.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes.addAll(publicRecipes);
    }

    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
  }

  void endLoading() {
    this.isLoading = false;
  }
}
