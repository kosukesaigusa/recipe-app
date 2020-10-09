import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel()..fetchRecipe(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("マイページ"),
        ),
        body: Text('マイページ'),
      ),
    );
  }
}
