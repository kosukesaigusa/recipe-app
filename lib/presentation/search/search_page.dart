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
      create: (_) => SearchModel()..fetchSearch(context),
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
                          /// とりあえず
                          for (int i = 0; i < model.recipes.length; i++)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width: size.width - 156,
                                        height: 100,
                                        //height: ,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Text(
                                                '${model.recipes[i].name}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${model.recipes[i].content}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                '${'${model.recipes[i].createdAt.toDate()}'.substring(0, 10)} ${_convertWeekdayName(model.recipes[i].createdAt.toDate().weekday)}',
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
                                          '${model.recipes[i].thumbnailURL}',
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    /// みんなのレシピ
                    Visibility(
                      visible: model.recipeTabIndex == 1,
                      maintainState: true,
                      child: Column(
                        children: [
                          /// とりあえず
                          for (int i = 0; i < 5; i++)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width: size.width - 156,
                                        height: 100,
                                        //height: ,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Text(
                                                'みんなの豚キムチチチチチチチチチチチチチチチチチチチチチチチチチチチ',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'まず豚こま肉を200g程度、塩胡椒と薄力粉でコーティングして下準備する。ニンニクは2片ほどを荒みじん切り、玉ねぎ半分を薄めのスライスにしておく。'
                                              '\n温めたフライパンにニンニクを入れて火を通し、柴犬色になったら肉をよく広げながら入れる。全体に火が通ってきたら玉ねぎを入れて、透明になるまで炒める。そこにキムチを投入して、酒大さじ1、醤油小さじ1、佐藤小さじ1、めんつゆ少々を加えて、水分が少し減るくらいまで炒める。'
                                              '\nご飯によく合う味で美味しい！！',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                '2020年10月1日 (木)',
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
                                          'https://img.cpcdn.com/recipes/597693/840x1461s/3961a206a888b9997f627487663ab3a4?u=125911&p=1246605171',
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
                  : SizedBox()
            ],
          );
        },
      ),
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
