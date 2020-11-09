import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/my_account/my_account_page.dart';
import 'package:recipe/presentation/recipe/recipe_page.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_page.dart';
import 'package:recipe/presentation/search/search_model.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズを取得
    final Size _size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SearchModel>(
      create: (_) => SearchModel()..fetchRecipes(context),
      child: Consumer<SearchModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    leading: Container(),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.menu),
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
                              child: Text('わたしのレシピ'),
                            ),
                            Tab(
                              child: Text('みんなのレシピ'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  body: TabBarView(
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
                              initialValue: model.mySearchWords,
                              onChanged: (text) async {
                                model.changeMySearchWords(text);
                                if (text.isNotEmpty) {
                                  model.startMyRecipeFiltering();
                                  await model.filterMyRecipe(text);
                                } else {
                                  model.endMyRecipeFiltering();
                                }
                              },
                              maxLines: 1,
                              decoration: InputDecoration(
                                errorText: model.mySearchErrorText == ''
                                    ? null
                                    : model.mySearchErrorText,
                                labelText: 'レシピ名 や 材料名 で検索',
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontSize: 12.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              key: PageStorageKey(0), // スクロール位置の保存に必要
                              children: [
                                /// わたしのレシピをFirestoreから取得
                                Column(
                                  children: [
                                    model.isMyRecipeFiltering
                                        ? _recipeCards(
                                            model.filteredMyRecipes,
                                            _size,
                                            model.userId,
                                            'my_tab',
                                            context)
                                        : _recipeCards(model.myRecipes, _size,
                                            model.userId, 'my_tab', context),
                                    FlatButton(
                                      onPressed: model.isMyRecipeFiltering
                                          ? model.canLoadMoreFilteredMyRecipe
                                              ? () async {
                                                  await model
                                                      .loadMoreFilteredMyRecipes();
                                                }
                                              : null
                                          : model.canLoadMoreMyRecipe
                                              ? () async {
                                                  await model
                                                      .loadMoreMyRecipes();
                                                }
                                              : null,
                                      child: model.isFiltering
                                          ? Text('検索中...')
                                          : model.isLoading
                                              ? SizedBox()
                                              : model.isMyRecipeFiltering
                                                  ? model
                                                          .canLoadMoreFilteredMyRecipe
                                                      ? Text('検索結果をさらに読み込む')
                                                      : model
                                                              .existsFilteredMyRecipe
                                                          ? Text('検索結果は以上です')
                                                          : Text('検索結果が見つかりません')
                                                  : model.canLoadMoreMyRecipe
                                                      ? Text('さらに読み込む')
                                                      : model.existsMyRecipe
                                                          ? Text('以上です')
                                                          : Text(
                                                              'まだレシピが登録されていません'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                              initialValue: model.publicSearchWords,
                              onChanged: (text) async {
                                model.changePublicSearchWords(text);
                                if (text.isNotEmpty) {
                                  model.startPublicRecipeFiltering();
                                  await model.filterPublicRecipe(text);
                                } else {
                                  model.endPublicRecipeFiltering();
                                }
                              },
                              maxLines: 1,
                              decoration: InputDecoration(
                                errorText: model.publicSearchErrorText == ''
                                    ? null
                                    : model.publicSearchErrorText,
                                labelText: 'レシピ名 や 材料名 で検索',
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontSize: 12.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              key: PageStorageKey(1), // スクロール位置の保存に必要
                              children: [
                                /// みんなのレシピをFirestoreから取得
                                Column(
                                  children: [
                                    model.isPublicRecipeFiltering
                                        ? _recipeCards(
                                            model.filteredPublicRecipes,
                                            _size,
                                            model.userId,
                                            'public_tab',
                                            context)
                                        : _recipeCards(
                                            model.publicRecipes,
                                            _size,
                                            model.userId,
                                            'public_tab',
                                            context),
                                    FlatButton(
                                      onPressed: model.isPublicRecipeFiltering
                                          ? model.canLoadMoreFilteredPublicRecipe
                                              ? () async {
                                                  await model
                                                      .loadMoreFilteredPublicRecipes();
                                                }
                                              : null
                                          : model.canLoadMorePublicRecipe
                                              ? () async {
                                                  await model
                                                      .loadMorePublicRecipes();
                                                }
                                              : null,
                                      child: model.isFiltering
                                          ? Text('検索中...')
                                          : model.isLoading
                                              ? SizedBox()
                                              : model.isPublicRecipeFiltering
                                                  ? model.canLoadMoreFilteredPublicRecipe
                                                      ? Text('検索結果をさらに読み込む')
                                                      : model.existsFilteredPublicRecipe
                                                          ? Text('検索結果は以上です')
                                                          : Text('検索結果が見つかりません')
                                                  : model.canLoadMorePublicRecipe
                                                      ? Text('さらに読み込む')
                                                      : model.existsPublicRecipe
                                                          ? Text('以上です')
                                                          : Text('まだレシピが登録されていません'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeAddPage(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
              model.isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(),
            ],
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
                              '${'${recipes[i].createdAt.toDate()}'.substring(0, 10)} '
                              '${_convertWeekdayName(recipes[i].createdAt.toDate().weekday)}',
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
                                  color: Color(0xFFDADADA),
                                  width: 100,
                                  height: 100,
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
                                  errorWidget: (context, url, error) =>
                                      //Icon(Icons.error),
                                      Container(
                                    color: Color(0xFFDADADA),
                                    width: 100,
                                    height: 100,
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
                                  color: Color(0xFFFFCC00),
                                  child: Center(
                                    child: Text(
                                      '公開中',
                                      style: TextStyle(
                                        color: Color(0xFF0033FF),
                                        fontSize: 8,
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
                                        fontSize: 8,
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
                                  color: Colors.blue,
                                  child: Center(
                                    child: Text(
                                      'わたしのレシピ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
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
