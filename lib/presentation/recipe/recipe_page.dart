import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_page.dart';
import 'package:recipe/common/text_dialog.dart';

class RecipePage extends StatelessWidget {
  RecipePage(this.recipeDocumentId, this.recipeOwnerId);

  final String recipeDocumentId;
  final String recipeOwnerId;
  Recipe recipe = null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel(recipeDocumentId, recipeOwnerId),
      child: Consumer<RecipeModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  if (model.recipe == null) {
                    showTextDialog(context, "レシピの詳細を取得できませんでした。");
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return RecipeDetailPage(model.recipe);
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
          bottomNavigationBar: SafeArea(
            bottom: false,
              child: Container(
                constraints: BoxConstraints(maxHeight: model.isMyRecipe ? 70.0 : 0),
                padding: EdgeInsets.only(left: 20.0, top:5, right: 20.0, bottom: 10),
                child: FlatButton(
                  color: Colors.lightBlue,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(2.0),
                  splashColor: Colors.blueAccent,
                  height: 45,
                  child: Text(
                    'レシピを編集する',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                        builder: (context) {
                          return RecipeEditPage(model.recipe);
                        },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    )
                    );
                  },
                ),
              ),
          ),
          body: Stack(
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
          ),
        );
      }),
    );
  }
}
