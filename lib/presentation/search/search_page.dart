import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/search/search_model.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchModel>(
      create: (_) => SearchModel()..fetchSearch(context),
      child: Consumer<SearchModel>(
        builder: (context, model, child) {
          if (model.isLoading == true) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('レシピの検索ページ'),
                Text('接続している Firebase プロジェクト：${model.firestoreEnv}'),
              ],
            );
          }
        },
      ),
    );
  }
}
