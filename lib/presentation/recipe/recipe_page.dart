import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_page.dart';

class RecipePage extends StatelessWidget {
  RecipePage(this.recipeDocumentId, this.recipeOwnerId);

  final String recipeDocumentId;
  final String recipeOwnerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel(recipeDocumentId, recipeOwnerId),
      child: Consumer<RecipeModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.loupe),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return RecipeDetailPage(model.recipe);
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return RecipeEditPage(model.recipe);
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            ],
            centerTitle: true,
            title: model.isLoading ? SizedBox() : Text('${model.recipe.name}'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      model.isLoading
                          ? SizedBox()
                          : model.isMyRecipe
                              ? model.isPublic
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            color: Colors.blue,
                                            child: Text(
                                              'わたしのレシピ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            color: Color(0xFFFFCC00),
                                            child: Text(
                                              '公開中',
                                              style: TextStyle(
                                                color: Color(0xFF0033FF),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            color: Colors.blue,
                                            child: Text(
                                              'わたしのレシピ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            color: Colors.grey,
                                            child: Text(
                                              '非公開',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                              : Container(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(4.0),
                                    color: Colors.red,
                                    child: Text(
                                      'みんなのレシピ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        'レシピ名',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text('${model.name}'),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 150,
                          child: model.isLoading
                              ? Container(
                                  color: Color(0xFFDADADA),
                                  width: 100,
                                  height: 100,
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
                                )
                              : '${model.imageURL}' == ''
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
                                      imageUrl: '${model.imageURL}',
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
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        '作り方・材料',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text('${model.content}'),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        '参考にしたレシピ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text('${model.content}'),
                    ],
                  ),
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
          ),
        );
      }),
    );
  }
}
