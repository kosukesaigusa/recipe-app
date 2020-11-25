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

  final currentUserId = FirebaseAuth.instance.currentUser.uid;

  Future<void> fetchRecipe() async {
    startLoading();
    bool _isMyRecipe = this.recipe.userId == this.userId;
    // 元のレシピインスタンスのお気に入りの状態を保管しておく
    bool _isFavorite = this.recipe.isFavorite;
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
        // お気に入りのステイタスを元の状態に戻す
        this.recipe.isFavorite = _isFavorite;
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

  // お気に入りボタンを押した時の処理
  Future<void> pressedFavoriteButton() async {
    // 元の ON/OFF の状態
    bool _oldState = this.recipe.isFavorite;

    // お気に入りの ON/OFF を切り替える
    switchFavoriteState(_oldState);

    // 対象をお気に入りから削除する
    if (_oldState) {
      await FirebaseFirestore.instance
          .collection('users/${this.currentUserId}/favorite_recipes')
          .doc(this.recipe.documentId)
          .delete();
    }
    // 対象をお気に入りに追加する
    else {
      DocumentSnapshot _doc;

      /// 対象が他人のレシピの場合
      /// ※ 自分が公開している「みんなのレシピ」を除く
      if (this.recipe.documentId.startsWith('public_')) {
        _doc = await FirebaseFirestore.instance
            .collection('public_recipes')
            .doc(this.recipe.documentId)
            .get();
      }

      /// 対象が自分のレシピの場合
      /// ※ 自分が公開している「みんなのレシピ」を含む
      else {
        _doc = await FirebaseFirestore.instance
            .collection('users/${this.userId}/recipes')
            .doc(this.recipe.documentId)
            .get();
      }

      Map _fields = _doc.data();
      _fields['likedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('users/${this.currentUserId}/favorite_recipes')
          .doc(this.recipe.documentId)
          .set(_fields);
    }
  }

  void switchFavoriteState(bool input) {
    this.recipe.isFavorite = !input;
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
