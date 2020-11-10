import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_model.dart';

class RecipeDetailPage extends StatelessWidget {
  RecipeDetailPage(this.recipe);

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeDetailModel>(
      create: (_) => RecipeDetailModel(recipe),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Consumer<RecipeDetailModel>(builder: (context, model, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        "作り方・材料",
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
          );
        }),
      ),
    );
  }
}
