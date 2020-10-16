import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/search/search_model.dart';

class SearchPage extends StatelessWidget {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズを取得
    final Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SearchModel>(
      create: (_) => SearchModel()..fetchRecipes(context),
      child: Consumer<SearchModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: model.recipeTabIndex == 0
                                    ? Colors.blue
                                    : Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: FlatButton(
                            onPressed: () {
                              // 「わたしのレシピ」の方をアクティブに
                              model.onRecipeTabTapped(0);
                            },
                            child: Text(
                              'わたしのレシピ',
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: model.recipeTabIndex == 1
                                    ? Colors.blue
                                    : Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: FlatButton(
                            onPressed: () {
                              // 「わたしのレシピ」の方をアクティブに
                              model.onRecipeTabTapped(1);
                            },
                            child: Text('みんなのレシピ'),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 8.0, right: 8.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (text) {},
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'レシピ名 や 材料名 で検索',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: 12.0,
                          height: 1.0,
                        ),
                      ),
                    ),

                    /// わたしのレシピをFirestoreから取得
                    Visibility(
                      visible: model.recipeTabIndex == 0,
                      maintainState: true,
                      child: Column(
                        children: [
                          _recipeCards(model.myRecipes, size),
                          FlatButton(
                            onPressed: () async {
                              await model.fetchMoreMyRecipes();
                            },
                            child: model.isMyRecipeLeft == true
                                ? Text('さらに読み込む')
                                : model.noMyRecipe == true
                                    ? Text('まだレシピが登録されていません')
                                    : Text('以上です'),
                          ),
                        ],
                      ),
                    ),

                    /// みんなのレシピをFirestoreから取得
                    Visibility(
                      visible: model.recipeTabIndex == 1,
                      maintainState: true,
                      child: Column(
                        children: [
                          _recipeCards(model.publicRecipes, size),
                          FlatButton(
                            onPressed: () async {
                              await model.fetchMorePublicRecipes();
                            },
                            child: model.isPublicRecipeLeft == true
                                ? Text('さらに読み込む')
                                : model.noPublicRecipe == true
                                    ? Text('まだレシピが登録されていません')
                                    : Text('以上です'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              model.isLoading
                  ? Container(
                      color: Colors.black.withOpacity(0.3),
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

  // レシピのカード一覧のウィジェトを返す関数
  Widget _recipeCards(List recipes, Size size) {
    // 画面に表示するカードのリスト
    List<Widget> list = List<Widget>();
    for (int i = 0; i < recipes.length; i++) {
      // Card ウィジェットをループの個数だけリストに追加する
      list.add(
        Card(
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${recipes[i].name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${recipes[i].content}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${'${recipes[i].createdAt.toDate()}'.substring(0, 10)} ${_convertWeekdayName(recipes[i].createdAt.toDate().weekday)}',
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
                  child: SizedBox(
                    width: 100,
                    child: Image.network(
                      '${recipes[i].thumbnailURL}',
                    ),
                  ),
                )
              ],
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
