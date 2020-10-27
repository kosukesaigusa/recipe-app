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
        appBar: AppBar(
          centerTitle: true,
          title: Icon(
            Icons.restaurant,
            color: Colors.white,
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
                      Text(
                        "作り方・材料",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        model.content,
                        style: TextStyle(
                            fontSize: 20
                        ),
                      ),
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
