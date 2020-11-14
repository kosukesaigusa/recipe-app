import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/will_pop_scope.dart';
import 'package:recipe/presentation/my_account/my_account_page.dart';
import 'package:recipe/presentation/recipe/recipe_page.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_page.dart';
import 'package:recipe/presentation/search/search_model.dart';
import 'package:vibrate/vibrate.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズを取得
    final Size _size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SearchModel>(
      create: (_) => SearchModel()..fetchRecipes(context),
      child: Consumer<SearchModel>(
        builder: (context, model, child) {
          return WillPopScope(
            onWillPop: willPopCallback,
            child: Stack(
              children: [
                DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(48.0),
                      child: AppBar(
                        leading: Container(),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyAccountPage(),
                                ),
                              );
                            },
                          ),
                        ],
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TabBar(
                              isScrollable: true,
                              tabs: [
                                Tab(
                                  child: Text(
                                    'わたしのレシピ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Text(
                                    'みんなのレシピ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        /// 「わたしのレシピ」タブ
                        Stack(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 16.0,
                                  ),
                                  child: TextFormField(
                                    controller:
                                        model.myRecipeTab.textController,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (text) async {
                                      model.changeMySearchWords(text);
                                      if (text.isNotEmpty) {
                                        model.myRecipeTab.showFilteredRecipe =
                                            true;
                                        model.startMyRecipeFiltering();
                                        await model.filterMyRecipe(text);
                                      } else {
                                        model.myRecipeTab.showFilteredRecipe =
                                            false;
                                        model.endMyRecipeFiltering();
                                      }
                                    },
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      errorText:
                                          model.myRecipeTab.errorText == ''
                                              ? null
                                              : model.myRecipeTab.errorText,
                                      labelText: 'レシピ名・材料名（スペース区切りの複数単語可）',
                                      border: OutlineInputBorder(),
                                      suffixIcon: model.myRecipeTab
                                              .textController.text.isEmpty
                                          ? SizedBox()
                                          : IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                model.myRecipeTab.textController
                                                    .clear();
                                                model.myRecipeTab
                                                    .showFilteredRecipe = false;
                                                model.myRecipeTab.errorText =
                                                    '';
                                                model.endMyRecipeFiltering();
                                              },
                                            ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                // Container(
                                //   width: 30,
                                //   height: 30,
                                //   color: Colors.red,
                                //   child: CircularProgressIndicator(),
                                // ),
                                Expanded(
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification _notification) {
                                      /// Load more:
                                      if (_notification.metrics.pixels ==
                                          _notification
                                              .metrics.maxScrollExtent) {
                                        if (model.myRecipeTab.isLoadingMore) {
                                          // 前のクエリを取得中の場合は待つ
                                        } else {
                                          if (model
                                              .myRecipeTab.showFilteredRecipe) {
                                            // 絞り込み中の場合
                                            if (model.myRecipeTab
                                                .canLoadMoreFiltered) {
                                              model.loadMoreFilteredMyRecipes();
                                            }
                                          } else {
                                            // 絞り込み中でない場合
                                            if (model.myRecipeTab.canLoadMore) {
                                              model.loadMoreMyRecipes();
                                            }
                                          }
                                        }
                                      }

                                      /// Reload:
                                      if (_notification.metrics.pixels == 0) {
                                        model.canReload = true;
                                      }
                                      if (_notification.metrics.pixels < -100) {
                                        if (model.canReload &&
                                            !model.myRecipeTab.isLoading) {
                                          model.canReload = false;
                                          Vibrate.feedback(FeedbackType.medium);
                                          model.loadMyRecipes();
                                        }
                                      }
                                      return false;
                                    },
                                    child: ListView(
                                      key: PageStorageKey(0), // スクロール位置の保存に必要
                                      children: [
                                        /// わたしのレシピをFirestoreから取得
                                        Column(
                                          children: [
                                            model.myRecipeTab.showFilteredRecipe
                                                ? _recipeCards(
                                                    model.myRecipeTab
                                                        .filteredRecipes,
                                                    _size,
                                                    model.userId,
                                                    'my_tab',
                                                    context)
                                                : _recipeCards(
                                                    model.myRecipeTab.recipes,
                                                    _size,
                                                    model.userId,
                                                    'my_tab',
                                                    context),
                                            FlatButton(
                                              onPressed: model.myRecipeTab
                                                      .showFilteredRecipe
                                                  ? model.myRecipeTab
                                                          .canLoadMoreFiltered
                                                      ? () async {
                                                          await model
                                                              .loadMoreFilteredMyRecipes();
                                                        }
                                                      : null
                                                  : model.myRecipeTab
                                                          .canLoadMore
                                                      ? () async {
                                                          await model
                                                              .loadMoreMyRecipes();
                                                        }
                                                      : null,
                                              child: model
                                                      .myRecipeTab.isFiltering
                                                  ? Text('検索中...')
                                                  : model.myRecipeTab.isLoading
                                                      ? SizedBox()
                                                      : model.myRecipeTab
                                                              .showFilteredRecipe
                                                          ? model.myRecipeTab
                                                                  .canLoadMoreFiltered
                                                              ? Text(
                                                                  '検索結果をさらに読み込む')
                                                              : model.myRecipeTab
                                                                      .existsFilteredRecipe
                                                                  ? Text(
                                                                      '検索結果は以上です')
                                                                  : Text(
                                                                      '検索結果が見つかりません')
                                                          : model.myRecipeTab
                                                                  .canLoadMore
                                                              ? Text('さらに読み込む')
                                                              : model.myRecipeTab
                                                                      .existsRecipe
                                                                  ? Text('以上です')
                                                                  : Text(
                                                                      'まだレシピが登録されていません'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            model.myRecipeTab.isLoading
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),

                        /// 「みんなのレシピ」タブ
                        Stack(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 16.0,
                                  ),
                                  child: TextFormField(
                                    controller:
                                        model.publicRecipeTab.textController,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (text) async {
                                      model.changePublicSearchWords(text);
                                      if (text.isNotEmpty) {
                                        model.publicRecipeTab
                                            .showFilteredRecipe = true;
                                        model.startPublicRecipeFiltering();
                                        await model.filterPublicRecipe(text);
                                      } else {
                                        model.publicRecipeTab
                                            .showFilteredRecipe = false;
                                        model.endPublicRecipeFiltering();
                                      }
                                    },
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      errorText:
                                          model.publicRecipeTab.errorText == ''
                                              ? null
                                              : model.publicRecipeTab.errorText,
                                      labelText: 'レシピ名・材料名（スペース区切りの複数単語可）',
                                      border: OutlineInputBorder(),
                                      suffixIcon: model.publicRecipeTab
                                              .textController.text.isEmpty
                                          ? SizedBox()
                                          : IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                model.publicRecipeTab
                                                    .textController
                                                    .clear();
                                                model.publicRecipeTab
                                                    .showFilteredRecipe = false;
                                                model.publicRecipeTab
                                                    .errorText = '';
                                                model
                                                    .endPublicRecipeFiltering();
                                              },
                                            ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification _notification) {
                                      /// Load more:
                                      if (_notification.metrics.pixels ==
                                          _notification
                                              .metrics.maxScrollExtent) {
                                        if (model
                                            .publicRecipeTab.isLoadingMore) {
                                          // 前のクエリを取得中の場合は待つ
                                        } else {
                                          if (model.publicRecipeTab
                                              .showFilteredRecipe) {
                                            // 絞り込み中の場合
                                            if (model.publicRecipeTab
                                                .canLoadMoreFiltered) {
                                              model
                                                  .loadMoreFilteredPublicRecipes();
                                            }
                                          } else {
                                            // 絞り込み中でない場合
                                            if (model
                                                .publicRecipeTab.canLoadMore) {
                                              model.loadMorePublicRecipes();
                                            }
                                          }
                                        }
                                      }

                                      /// Reload:
                                      if (_notification.metrics.pixels == 0) {
                                        model.canReload = true;
                                      }
                                      if (_notification.metrics.pixels < -100) {
                                        if (model.canReload &&
                                            !model.myRecipeTab.isLoading) {
                                          model.canReload = false;
                                          Vibrate.feedback(FeedbackType.medium);
                                          model.loadPublicRecipes();
                                        }
                                      }
                                      return false;
                                    },
                                    child: ListView(
                                      key: PageStorageKey(1), // スクロール位置の保存に必要
                                      children: [
                                        Column(
                                          children: [
                                            model.publicRecipeTab
                                                    .showFilteredRecipe
                                                ? _recipeCards(
                                                    model.publicRecipeTab
                                                        .filteredRecipes,
                                                    _size,
                                                    model.userId,
                                                    'public_tab',
                                                    context)
                                                : _recipeCards(
                                                    model.publicRecipeTab
                                                        .recipes,
                                                    _size,
                                                    model.userId,
                                                    'public_tab',
                                                    context),
                                            FlatButton(
                                              onPressed: model.publicRecipeTab
                                                      .showFilteredRecipe
                                                  ? model.publicRecipeTab
                                                          .canLoadMoreFiltered
                                                      ? () async {
                                                          await model
                                                              .loadMoreFilteredPublicRecipes();
                                                        }
                                                      : null
                                                  : model.publicRecipeTab
                                                          .canLoadMore
                                                      ? () async {
                                                          await model
                                                              .loadMorePublicRecipes();
                                                        }
                                                      : null,
                                              child: model.publicRecipeTab
                                                      .isFiltering
                                                  ? Text('検索中...')
                                                  : model.publicRecipeTab
                                                          .isLoading
                                                      ? SizedBox()
                                                      : model.publicRecipeTab
                                                              .showFilteredRecipe
                                                          ? model.publicRecipeTab
                                                                  .canLoadMoreFiltered
                                                              ? Text(
                                                                  '検索結果をさらに読み込む')
                                                              : model.publicRecipeTab
                                                                      .existsFilteredRecipe
                                                                  ? Text(
                                                                      '検索結果は以上です')
                                                                  : Text(
                                                                      '検索結果が見つかりません')
                                                          : model.publicRecipeTab
                                                                  .canLoadMore
                                                              ? Text('さらに読み込む')
                                                              : model.publicRecipeTab
                                                                      .existsRecipe
                                                                  ? Text('以上です')
                                                                  : Text(
                                                                      'まだレシピが登録されていません'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            model.publicRecipeTab.isLoading
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ],
                    ),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeAddPage(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// レシピのカード一覧のウィジェトを返す関数
  Widget _recipeCards(
      List recipes, Size size, String userId, String tab, context) {
    bool isMyRecipe;
    // 画面に表示するカードのリスト
    List<Widget> list = List<Widget>();
    for (int i = 0; i < recipes.length; i++) {
      isMyRecipe = recipes[i].userId == userId;
      // Card ウィジェットをループの個数だけリストに追加する
      list.add(
        Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              color: Color(0xFFDADADA),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return RecipePage(recipes[i].documentId, recipes[i].userId);
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: size.width - 156,
                      height: 100,
                      //height: ,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 26,
                            child: Text(
                              '${recipes[i].name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Container(
                            height: 50,
                            child: Text(
                              '${recipes[i].content}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Container(
                            height: 16,
                            child: Text(
                              '${'${recipes[i].updatedAt.toDate()}'.substring(0, 10)} '
                              '${_convertWeekdayName(recipes[i].updatedAt.toDate().weekday)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 100,
                          child: '${recipes[i].thumbnailURL}' == ''
                              ? Container(
                                  width: 100,
                                  height: 75,
                                  color: Color(0xFFDADADA),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No photo',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: '${recipes[i].thumbnailURL}',
                                  placeholder: (context, url) => Container(
                                    width: 100,
                                    height: 75,
                                    color: Color(0xFFDADADA),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Loading...',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      //Icon(Icons.error),
                                      Container(
                                    color: Color(0xFFDADADA),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.error_outline),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        tab == 'my_tab' && isMyRecipe && recipes[i].isPublic
                            ? Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  color: Color(0xFFF39800),
                                  child: Center(
                                    child: Text(
                                      '公開中',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        tab == 'my_tab' &&
                                isMyRecipe &&
                                recipes[i].isPublic == false
                            ? Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      '非公開',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        tab == 'public_tab' && isMyRecipe && recipes[i].isPublic
                            ? Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  color: Color(0xFFF39800),
                                  child: Center(
                                    child: Text(
                                      'わたし',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: list,
    );
  }

  // 1〜7の数値を入力して、日本語の曜日名を返す
  String _convertWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '(月)';
      case 2:
        return '(火)';
      case 3:
        return '(水)';
      case 4:
        return '(木)';
      case 5:
        return '(金)';
      case 6:
        return '(土)';
      case 7:
        return '(日)';
      default:
        return '';
    }
  }
}
