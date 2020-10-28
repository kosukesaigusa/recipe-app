import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:recipe/domain/recipe.dart';

class RecipePage extends StatelessWidget {
  RecipePage(this.recipeDocumentId, this.recipeOwnerId);

  final String recipeDocumentId;
  final String recipeOwnerId;
  Recipe recipe=null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel(recipeDocumentId, recipeOwnerId),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (this.recipe == null) {
                  showDialog(context: context,builder:(_) {
                    return AlertDialog(
                      title: Text("エラー"),
                      content: Text("レシピの詳細を取得できませんでした。"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  });
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return RecipeDetailPage(this.recipe);
                    },
                  ),
                );
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.loupe, color: Colors.white, size: 28,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "拡大する",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ]
              )
            ),
          ],
          centerTitle: true,
          title: Icon(
            Icons.restaurant,
            color: Colors.white,
          ),
        ),
        body: Consumer<RecipeModel>(builder: (context, model, child) {
          this.recipe=model.recipe;
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(
                            color: Color(0xFFDADADA),
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                ),
                                child: Text(
                                  model.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              model.isMyRecipe
                                  ? IconButton(
                                onPressed: () {
                                  // edit page
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      model.imageURL == ''
                          ? SizedBox()
                          : Image.network(
                        '${model.imageURL}',
                      ),
                      SizedBox(height: 16),
                      Text(
                        "作り方・材料",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      Text(model.content),
                      SizedBox(height: 16),
                      Text(
                        "参考にしたレシピ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      Text(model.content),
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
          );
        }),
      ),
    );
  }
}
