import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeDetailModel extends ChangeNotifier {
  String name;
  String content;

  RecipeDetailModel(Recipe _recipe) {
    this.name = _recipe.name;
    this.content = _recipe.content;
  }
}
