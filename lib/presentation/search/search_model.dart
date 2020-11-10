import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class SearchModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = '';
  String mySearchErrorText = '';
  String publicSearchErrorText = '';
  bool isLoading;
  bool isFiltering = false;
  int loadLimit = 10;
  List myRecipes = [];
  List publicRecipes = [];
  List filteredMyRecipes = [];
  List filteredPublicRecipes = [];
  QueryDocumentSnapshot myLastVisible;
  QueryDocumentSnapshot publicLastVisible;
  QueryDocumentSnapshot filteredMyLastVisible;
  QueryDocumentSnapshot filteredPublicLastVisible;
  bool canLoadMoreMyRecipe = true;
  bool canLoadMorePublicRecipe = true;
  bool canLoadMoreFilteredMyRecipe = true;
  bool canLoadMoreFilteredPublicRecipe = true;
  bool existsMyRecipe;
  bool existsPublicRecipe;
  bool existsFilteredMyRecipe;
  bool existsFilteredPublicRecipe;
  bool isMyRecipeFiltering = false;
  bool isPublicRecipeFiltering = false;
  Query myFilterQuery;
  Query publicFilterQuery;
  TextEditingController mySearchController = TextEditingController();
  TextEditingController publicSearchController = TextEditingController();

  Future fetchRecipes(context) async {
    startLoading();

    if (_auth.currentUser == null) {
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
    QuerySnapshot _mySnap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_mySnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.existsMyRecipe = false;
      this.canLoadMoreMyRecipe = false;
      this.myRecipes = [];
    } else if (_mySnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.existsMyRecipe = true;
      this.canLoadMoreMyRecipe = false;
      this.myLastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes = _myRecipes;
    } else {
      /// 10件以上存在する場合
      this.existsMyRecipe = true;
      this.canLoadMoreMyRecipe = true;
      this.myLastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes = _myRecipes;
    }

    /// みんなのレシピ
    QuerySnapshot _publicSnap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_publicSnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.existsPublicRecipe = false;
      this.canLoadMorePublicRecipe = false;
      this.publicRecipes = [];
    } else if (_publicSnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.existsPublicRecipe = true;
      this.canLoadMorePublicRecipe = false;
      this.publicLastVisible = _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes = _publicRecipes;
    } else {
      /// 10件以上存在する場合
      this.existsPublicRecipe = true;
      this.canLoadMorePublicRecipe = true;
      this.publicLastVisible = _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes = _publicRecipes;
    }

    endLoading();
    notifyListeners();
  }

  /// わたしのレシピをさらに10件取得
  Future loadMoreMyRecipes() async {
    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.myLastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.canLoadMoreMyRecipe = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.canLoadMoreMyRecipe = false;
      this.myLastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes.addAll(_moreRecipes);
    } else {
      this.canLoadMoreMyRecipe = true;
      this.myLastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipes.addAll(_moreRecipes);
    }

    notifyListeners();
  }

  /// みんなのレシピをさらに10件取得
  Future loadMorePublicRecipes() async {
    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.publicLastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.canLoadMorePublicRecipe = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.canLoadMorePublicRecipe = false;
      this.publicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes.addAll(_moreRecipes);
    } else {
      this.canLoadMorePublicRecipe = true;
      this.publicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipes.addAll(_moreRecipes);
    }

    notifyListeners();
  }

  Future filterMyRecipe(String input) async {
    /// ひとつ前の検索処理が終わっていない場合は少し待つ
    if (this.isFiltering) {
      await Future.delayed(new Duration(milliseconds: 500));
    }

    /// ステイタスを検索中に更新
    startFiltering();

    /// 検索用フィールドに入力された文字列の前処理
    List<String> _words = input.trim().split(' ');

    /// 文字列のリストを渡して、bi-gram を実行
    List tokens = tokenize(_words);

    /// クエリの生成（bi-gram の結果のトークンマップを where 句に反映）
    Query _query =
        FirebaseFirestore.instance.collection('users/$userId/recipes');
    tokens.forEach((word) {
      _query =
          _query.where('tokenMap.$word', isEqualTo: true).limit(this.loadLimit);
    });

    /// 検索に用いたクエリをクラス変数に保存
    this.myFilterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.existsFilteredMyRecipe = false;
      this.canLoadMoreFilteredMyRecipe = false;
      this.filteredMyRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.existsFilteredMyRecipe = true;
      this.canLoadMoreFilteredMyRecipe = false;
      this.filteredMyLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredMyRecipes = _filteredRecipes;
    } else {
      this.existsFilteredMyRecipe = true;
      this.canLoadMoreFilteredMyRecipe = true;
      this.filteredMyLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredMyRecipes = _filteredRecipes;
    }

    /// ステイタスを検索終了に更新
    endFiltering();
    notifyListeners();
  }

  Future filterPublicRecipe(String input) async {
    /// ひとつ前の検索処理が終わっていない場合は少し待つ
    if (this.isFiltering) {
      await Future.delayed(new Duration(milliseconds: 500));
    }

    /// ステイタスを検索中に更新
    startFiltering();

    /// 検索用フィールドに入力された文字列の前処理
    List<String> _words = input.trim().split(' ');

    /// 文字列のリストを渡して、bi-gram を実行
    List tokens = tokenize(_words);

    /// クエリの生成（bi-gram の結果のトークンマップを where 句に反映）
    Query _query = FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true);
    tokens.forEach((word) {
      _query =
          _query.where('tokenMap.$word', isEqualTo: true).limit(this.loadLimit);
    });

    /// 検索に用いたクエリをクラス変数に保存
    this.publicFilterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.existsFilteredPublicRecipe = false;
      this.canLoadMoreFilteredPublicRecipe = false;
      this.filteredPublicRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.existsFilteredPublicRecipe = true;
      this.canLoadMoreFilteredPublicRecipe = false;
      this.filteredPublicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredPublicRecipes = _filteredRecipes;
    } else {
      this.existsFilteredPublicRecipe = true;
      this.canLoadMoreFilteredPublicRecipe = true;
      this.filteredPublicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredPublicRecipes = _filteredRecipes;
    }

    /// ステイタスを検索終了に更新
    endFiltering();
    notifyListeners();
  }

  Future loadMoreFilteredMyRecipes() async {
    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .myFilterQuery
        .startAfterDocument(this.filteredMyLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.canLoadMoreFilteredMyRecipe = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.canLoadMoreFilteredMyRecipe = false;
      this.filteredMyLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredMyRecipes.addAll(_filteredRecipes);
    } else {
      this.canLoadMoreFilteredMyRecipe = true;
      this.filteredMyLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredMyRecipes.addAll(_filteredRecipes);
    }

    notifyListeners();
  }

  Future loadMoreFilteredPublicRecipes() async {
    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .publicFilterQuery
        .startAfterDocument(this.filteredPublicLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.canLoadMoreFilteredPublicRecipe = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.canLoadMoreFilteredPublicRecipe = false;
      this.filteredPublicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredPublicRecipes.addAll(_filteredRecipes);
    } else {
      this.canLoadMoreFilteredPublicRecipe = true;
      this.filteredPublicLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.filteredPublicRecipes.addAll(_filteredRecipes);
    }

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

  void startFiltering() {
    this.isFiltering = true;
    notifyListeners();
  }

  void endFiltering() {
    this.isFiltering = false;
    notifyListeners();
  }

  void startMyRecipeFiltering() {
    this.isMyRecipeFiltering = true;
    notifyListeners();
  }

  void endMyRecipeFiltering() {
    this.isMyRecipeFiltering = false;
    this.mySearchErrorText = '';
    notifyListeners();
  }

  void startPublicRecipeFiltering() {
    this.isPublicRecipeFiltering = true;
    notifyListeners();
  }

  void endPublicRecipeFiltering() {
    this.isPublicRecipeFiltering = false;
    this.publicSearchErrorText = '';
    notifyListeners();
  }

  void changeMySearchWords(text) {
    if (text.length == 1) {
      this.mySearchErrorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.mySearchErrorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.mySearchErrorText = '';
    }
    notifyListeners();
  }

  void changePublicSearchWords(text) {
    if (text.length == 1) {
      this.publicSearchErrorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.publicSearchErrorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.publicSearchErrorText = '';
    }
    notifyListeners();
  }
}
