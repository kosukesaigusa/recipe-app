import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/domain/recipe_tab.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class SearchModel extends ChangeNotifier {
  FirebaseAuth auth;
  MyRecipeTab myRecipeTab;
  PublicRecipeTab publicRecipeTab;
  FavoriteRecipeTab favoriteRecipeTab;
  String userId;
  int loadLimit;
  bool canReload;
  QuerySnapshot favoriteQuerySnapshot;
  List<String> favoriteDocIdList;

  SearchModel() {
    this.myRecipeTab = MyRecipeTab();
    this.publicRecipeTab = PublicRecipeTab();
    this.favoriteRecipeTab = FavoriteRecipeTab();
    this.auth = FirebaseAuth.instance;
    this.userId = '';
    this.loadLimit = 10;
    this.canReload = true;
  }

  Future<void> fetchRecipes(context) async {
    startMyTabLoading();
    startPublicTabLoading();
    startFavoriteTabLoading();
    if (auth.currentUser == null) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
    } else {
      this.userId = auth.currentUser.uid;
    }

    /// お気に入りに登録されている Document Id のリストを取得
    await getFavoriteList();

    /// それぞれのタブで表示する内容を取得
    await loadMyRecipes();
    await loadPublicRecipes();
    await loadFavoriteRecipes();
    notifyListeners();
  }

  Future<void> loadMyRecipes() async {
    startMyTabLoading();

    /// わたしのレシピ
    QuerySnapshot _mySnap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_mySnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.myRecipeTab.existsRecipe = false;
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.recipes = [];
    } else if (_mySnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.myRecipeTab.existsRecipe = true;
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.lastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes = _myRecipes;
    } else {
      /// 10件以上存在する場合
      this.myRecipeTab.existsRecipe = true;
      this.myRecipeTab.canLoadMore = true;
      this.myRecipeTab.lastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes = _myRecipes;
    }

    await checkMyRecipeFavoriteState();

    endMyTabLoading();
    hideMyLoadingWidget();
    notifyListeners();
  }

  Future<void> loadPublicRecipes() async {
    startPublicTabLoading();

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
      this.publicRecipeTab.existsRecipe = false;
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.recipes = [];
    } else if (_publicSnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.publicRecipeTab.existsRecipe = true;
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.lastVisible =
          _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes = _publicRecipes;
    } else {
      /// 10件以上存在する場合
      this.publicRecipeTab.existsRecipe = true;
      this.publicRecipeTab.canLoadMore = true;
      this.publicRecipeTab.lastVisible =
          _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes = _publicRecipes;
    }

    await checkPublicRecipeFavoriteState();

    endPublicTabLoading();
    hidePublicLoadingWidget();
    notifyListeners();
  }

  Future<void> loadFavoriteRecipes() async {
    startFavoriteTabLoading();

    /// お気に入りのレシピ
    QuerySnapshot _favoriteSnap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/favorite_recipes')
        .orderBy('likedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_favoriteSnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.favoriteRecipeTab.existsRecipe = false;
      this.favoriteRecipeTab.canLoadMore = false;
      this.favoriteRecipeTab.recipes = [];
    } else if (_favoriteSnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.favoriteRecipeTab.existsRecipe = true;
      this.favoriteRecipeTab.canLoadMore = false;
      this.favoriteRecipeTab.lastVisible =
          _favoriteSnap.docs[_favoriteSnap.docs.length - 1];
      final _favoriteRecipes =
          _favoriteSnap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.recipes = _favoriteRecipes;
    } else {
      /// 10件以上存在する場合
      this.favoriteRecipeTab.existsRecipe = true;
      this.favoriteRecipeTab.canLoadMore = true;
      this.favoriteRecipeTab.lastVisible =
          _favoriteSnap.docs[_favoriteSnap.docs.length - 1];
      final _favoriteRecipes =
          _favoriteSnap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.recipes = _favoriteRecipes;
    }

    await checkFavoriteRecipeFavoriteState();

    endFavoriteTabLoading();
    hideFavoriteLoadingWidget();
    notifyListeners();
  }

  /// わたしのレシピをさらに10件取得
  Future<void> loadMoreMyRecipes() async {
    startLoadingMoreMyRecipe();

    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.myRecipeTab.lastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.canLoadMore = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes.addAll(_moreRecipes);
    } else {
      this.myRecipeTab.canLoadMore = true;
      this.myRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes.addAll(_moreRecipes);
    }

    await checkMyRecipeFavoriteState();

    endLoadingMoreMyRecipe();
    notifyListeners();
  }

  /// みんなのレシピをさらに10件取得
  Future loadMorePublicRecipes() async {
    startLoadingMorePublicRecipe();

    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.publicRecipeTab.lastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.canLoadMore = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes.addAll(_moreRecipes);
    } else {
      this.publicRecipeTab.canLoadMore = true;
      this.publicRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes.addAll(_moreRecipes);
    }

    await checkPublicRecipeFavoriteState();

    endLoadingMorePublicRecipe();
    notifyListeners();
  }

  /// お気に入りのレシピをさらに10件取得
  Future<void> loadMoreFavoriteRecipes() async {
    startLoadingMoreFavoriteRecipe();

    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/favorite_recipes')
        .orderBy('likedAt', descending: true)
        .startAfterDocument(this.favoriteRecipeTab.lastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.favoriteRecipeTab.canLoadMore = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.favoriteRecipeTab.canLoadMore = false;
      this.favoriteRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.recipes.addAll(_moreRecipes);
    } else {
      this.favoriteRecipeTab.canLoadMore = true;
      this.favoriteRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.recipes.addAll(_moreRecipes);
    }

    await checkFavoriteRecipeFavoriteState();

    endLoadingMoreFavoriteRecipe();
    notifyListeners();
  }

  Future<void> filterMyRecipe(String input) async {
    /// ステイタスを検索中に更新
    startMyRecipeFiltering();

    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.myRecipeTab.filteredRecipes = [];
      endMyRecipeFiltering();
      return;
    }

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
    this.myRecipeTab.filterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.existsFilteredRecipe = false;
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.existsFilteredRecipe = true;
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes = _filteredRecipes;
    } else {
      this.myRecipeTab.existsFilteredRecipe = true;
      this.myRecipeTab.canLoadMoreFiltered = true;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes = _filteredRecipes;
    }

    await checkMyFilteredRecipeFavoriteState();

    /// ステイタスを検索終了に更新
    endMyRecipeFiltering();
    notifyListeners();
  }

  Future<void> filterPublicRecipe(String input) async {
    /// ステイタスを検索中に更新
    startPublicRecipeFiltering();

    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.publicRecipeTab.filteredRecipes = [];
      endPublicRecipeFiltering();
      return;
    }

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
    this.publicRecipeTab.filterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.existsFilteredRecipe = false;
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.existsFilteredRecipe = true;
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes = _filteredRecipes;
    } else {
      this.publicRecipeTab.existsFilteredRecipe = true;
      this.publicRecipeTab.canLoadMoreFiltered = true;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes = _filteredRecipes;
    }

    await checkPublicFilteredRecipeFavoriteState();

    /// ステイタスを検索終了に更新
    endPublicRecipeFiltering();
    notifyListeners();
  }

  Future<void> filterFavoriteRecipe(String input) async {
    /// ステイタスを検索中に更新
    startFavoriteRecipeFiltering();

    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.favoriteRecipeTab.filteredRecipes = [];
      endFavoriteRecipeFiltering();
      return;
    }

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
    this.favoriteRecipeTab.filterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.favoriteRecipeTab.existsFilteredRecipe = false;
      this.favoriteRecipeTab.canLoadMoreFiltered = false;
      this.favoriteRecipeTab.filteredRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.favoriteRecipeTab.existsFilteredRecipe = true;
      this.favoriteRecipeTab.canLoadMoreFiltered = false;
      this.favoriteRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.filteredRecipes = _filteredRecipes;
    } else {
      this.favoriteRecipeTab.existsFilteredRecipe = true;
      this.favoriteRecipeTab.canLoadMoreFiltered = true;
      this.favoriteRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.filteredRecipes = _filteredRecipes;
    }

    await checkFavoriteFilteredRecipeFavoriteState();

    /// ステイタスを検索終了に更新
    endFavoriteRecipeFiltering();
    notifyListeners();
  }

  Future<void> loadMoreFilteredMyRecipes() async {
    startLoadingMoreMyRecipe();

    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .myRecipeTab
        .filterQuery
        .startAfterDocument(this.myRecipeTab.filteredLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.canLoadMoreFiltered = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    } else {
      this.myRecipeTab.canLoadMoreFiltered = true;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    }

    await checkMyFilteredRecipeFavoriteState();

    endLoadingMoreMyRecipe();
    notifyListeners();
  }

  Future<void> loadMoreFilteredPublicRecipes() async {
    startLoadingMorePublicRecipe();

    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .publicRecipeTab
        .filterQuery
        .startAfterDocument(this.publicRecipeTab.filteredLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.canLoadMoreFiltered = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    } else {
      this.publicRecipeTab.canLoadMoreFiltered = true;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    }

    await checkPublicFilteredRecipeFavoriteState();

    endLoadingMorePublicRecipe();
    notifyListeners();
  }

  Future<void> loadMoreFilteredFavoriteRecipes() async {
    startLoadingMoreFavoriteRecipe();

    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .favoriteRecipeTab
        .filterQuery
        .startAfterDocument(this.favoriteRecipeTab.filteredLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.favoriteRecipeTab.canLoadMoreFiltered = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.favoriteRecipeTab.canLoadMoreFiltered = false;
      this.favoriteRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    } else {
      this.favoriteRecipeTab.canLoadMoreFiltered = true;
      this.favoriteRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.favoriteRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    }

    await checkFavoriteFilteredRecipeFavoriteState();

    endLoadingMoreFavoriteRecipe();
    notifyListeners();
  }

  void startMyTabLoading() {
    this.myRecipeTab.isLoading = true;
    notifyListeners();
  }

  void endMyTabLoading() {
    this.myRecipeTab.isLoading = false;
    notifyListeners();
  }

  void startPublicTabLoading() {
    this.publicRecipeTab.isLoading = true;
    notifyListeners();
  }

  void endPublicTabLoading() {
    this.publicRecipeTab.isLoading = false;
    notifyListeners();
  }

  void startFavoriteTabLoading() {
    this.favoriteRecipeTab.isLoading = true;
    notifyListeners();
  }

  void endFavoriteTabLoading() {
    this.favoriteRecipeTab.isLoading = false;
    notifyListeners();
  }

  void startLoadingMoreMyRecipe() {
    this.myRecipeTab.isLoadingMore = true;
    notifyListeners();
  }

  void endLoadingMoreMyRecipe() {
    this.myRecipeTab.isLoadingMore = false;
    notifyListeners();
  }

  void startLoadingMorePublicRecipe() {
    this.publicRecipeTab.isLoadingMore = true;
    notifyListeners();
  }

  void endLoadingMorePublicRecipe() {
    this.publicRecipeTab.isLoadingMore = false;
    notifyListeners();
  }

  void startLoadingMoreFavoriteRecipe() {
    this.favoriteRecipeTab.isLoadingMore = true;
    notifyListeners();
  }

  void endLoadingMoreFavoriteRecipe() {
    this.favoriteRecipeTab.isLoadingMore = false;
    notifyListeners();
  }

  void startMyRecipeFiltering() {
    this.myRecipeTab.isFiltering = true;
    notifyListeners();
  }

  void endMyRecipeFiltering() {
    this.myRecipeTab.isFiltering = false;
    notifyListeners();
  }

  void startPublicRecipeFiltering() {
    this.publicRecipeTab.isFiltering = true;
    notifyListeners();
  }

  void endPublicRecipeFiltering() {
    this.publicRecipeTab.isFiltering = false;
    notifyListeners();
  }

  void startFavoriteRecipeFiltering() {
    this.favoriteRecipeTab.isFiltering = true;
    notifyListeners();
  }

  void endFavoriteRecipeFiltering() {
    this.favoriteRecipeTab.isFiltering = false;
    notifyListeners();
  }

  void hideMyLoadingWidget() {
    this.myRecipeTab.showReloadWidget = false;
    notifyListeners();
  }

  void hidePublicLoadingWidget() {
    this.publicRecipeTab.showReloadWidget = false;
    notifyListeners();
  }

  void hideFavoriteLoadingWidget() {
    this.favoriteRecipeTab.showReloadWidget = false;
    notifyListeners();
  }

  void changeMySearchWords(text) {
    if (text.length == 1) {
      this.myRecipeTab.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.myRecipeTab.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.myRecipeTab.errorText = '';
    }
    notifyListeners();
  }

  void changePublicSearchWords(text) {
    if (text.length == 1) {
      this.publicRecipeTab.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.publicRecipeTab.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.publicRecipeTab.errorText = '';
    }
    notifyListeners();
  }

  void changeFavoriteSearchWords(text) {
    if (text.length == 1) {
      this.favoriteRecipeTab.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.favoriteRecipeTab.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.favoriteRecipeTab.errorText = '';
    }
    notifyListeners();
  }

  Future<void> getFavoriteList() async {
    this.favoriteQuerySnapshot = await FirebaseFirestore.instance
        .collection('users/${this.userId}/favorite_recipes')
        // .limit(this.loadLimit)
        .get();
    this.favoriteDocIdList =
        this.favoriteQuerySnapshot.docs.map((e) => e.id).toList();

    notifyListeners();
  }

  void listenFavoriteRecipes() {
    Stream<QuerySnapshot> _querySnapshot = FirebaseFirestore.instance
        .collection('users/${this.userId}/favorite_recipes')
        .snapshots();

    /// users/{userId}/favorite_recipes コレクションの変更を監視して実行
    _querySnapshot.listen((snapshot) async {
      // お気に入りのドキュメント ID リストを再取得
      await getFavoriteList();
      // お気に入りのレシピタブに表示する内容を再取得
      await loadFavoriteRecipes();

      // 各タブで表示しているレシピカードのお気に入り状態を更新
      await checkMyRecipeFavoriteState();
      await checkPublicRecipeFavoriteState();
      notifyListeners();
    });
  }

  Future<void> checkMyRecipeFavoriteState() async {
    for (int i = 0; i < this.myRecipeTab.recipes.length; i++) {
      bool _flag = this.favoriteDocIdList.contains(
          this.myRecipeTab.recipes[i].documentId.replaceFirst('public_', ''));
      // お気に入り状態を更新
      this.myRecipeTab.recipes[i].isFavorite = _flag;
    }
    notifyListeners();
  }

  Future<void> checkMyFilteredRecipeFavoriteState() async {
    for (int i = 0; i < this.myRecipeTab.filteredRecipes.length; i++) {
      bool _flag = this.favoriteDocIdList.contains(this
          .myRecipeTab
          .filteredRecipes[i]
          .documentId
          .replaceFirst('public_', ''));
      // お気に入り状態を更新
      this.myRecipeTab.filteredRecipes[i].isFavorite = _flag;
    }
    notifyListeners();
  }

  Future<void> checkPublicRecipeFavoriteState() async {
    for (int i = 0; i < this.publicRecipeTab.recipes.length; i++) {
      // 公開しているものも含めて、自身のレシピの場合
      if (this.publicRecipeTab.recipes[i].userId == this.userId) {
        bool _flag = this.favoriteDocIdList.contains(this
            .publicRecipeTab
            .recipes[i]
            .documentId
            .replaceFirst('public_', ''));
        // お気に入り状態を更新
        this.publicRecipeTab.recipes[i].isFavorite = _flag;
      }
      // 他人のレシピの場合
      else {
        bool _flag = this
            .favoriteDocIdList
            .contains(this.publicRecipeTab.recipes[i].documentId);
        // お気に入り状態を更新
        this.publicRecipeTab.recipes[i].isFavorite = _flag;
      }
    }
    notifyListeners();
  }

  Future<void> checkFavoriteFilteredRecipeFavoriteState() async {
    for (int i = 0; i < this.favoriteRecipeTab.filteredRecipes.length; i++) {
      bool _flag = this.favoriteDocIdList.contains(this
          .favoriteRecipeTab
          .filteredRecipes[i]
          .documentId
          .replaceFirst('public_', ''));
      // お気に入り状態を更新
      this.favoriteRecipeTab.filteredRecipes[i].isFavorite = _flag;
    }
    notifyListeners();
  }

  Future<void> checkPublicFilteredRecipeFavoriteState() async {
    for (int i = 0; i < this.publicRecipeTab.filteredRecipes.length; i++) {
      // 公開しているものも含めて、自身のレシピの場合
      if (this.publicRecipeTab.filteredRecipes[i].userId == this.userId) {
        bool _flag = this.favoriteDocIdList.contains(this
            .publicRecipeTab
            .filteredRecipes[i]
            .documentId
            .replaceFirst('public_', ''));
        // お気に入り状態を更新
        this.publicRecipeTab.filteredRecipes[i].isFavorite = _flag;
      }
      // 他人のレシピの場合
      else {
        bool _flag = this
            .favoriteDocIdList
            .contains(this.publicRecipeTab.filteredRecipes[i].documentId);
        // お気に入り状態を更新
        this.publicRecipeTab.filteredRecipes[i].isFavorite = _flag;
      }
    }
    notifyListeners();
  }

  Future<void> checkFavoriteRecipeFavoriteState() async {
    for (int i = 0; i < this.favoriteRecipeTab.recipes.length; i++) {
      // 公開しているものも含めて、自身のレシピの場合
      if (this.favoriteRecipeTab.recipes[i].userId == this.userId) {
        bool _flag = this.favoriteDocIdList.contains(this
            .favoriteRecipeTab
            .recipes[i]
            .documentId
            .replaceFirst('public_', ''));
        // お気に入り状態を更新
        this.favoriteRecipeTab.recipes[i].isFavorite = _flag;
      }
      // 他人のレシピの場合
      else {
        bool _flag = this
            .favoriteDocIdList
            .contains(this.favoriteRecipeTab.recipes[i].documentId);
        // お気に入り状態を更新
        this.favoriteRecipeTab.recipes[i].isFavorite = _flag;
      }
    }
    notifyListeners();
  }
}
