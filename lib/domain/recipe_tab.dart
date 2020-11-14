import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MyRecipeTab {
  MyRecipeTab() {
    this.errorText = '';
    this.isLoading = false;
    this.isLoadingMore = false;
    this.recipes = [];
    this.filteredRecipes = [];
    this.lastVisible = null;
    this.filteredLastVisible = null;
    this.canLoadMore = false;
    this.canLoadMoreFiltered = false;
    this.existsRecipe = false;
    this.existsFilteredRecipe = false;
    this.isFiltering = false;
    this.showFilteredRecipe = false;
    this.filterQuery = null;
    this.textController = TextEditingController();
  }

  String errorText;
  bool isLoading;
  bool isLoadingMore;
  List recipes;
  List filteredRecipes;
  QueryDocumentSnapshot lastVisible;
  QueryDocumentSnapshot filteredLastVisible;
  bool canLoadMore;
  bool canLoadMoreFiltered;
  bool existsRecipe;
  bool existsFilteredRecipe;
  bool isFiltering;
  bool showFilteredRecipe;
  Query filterQuery;
  TextEditingController textController = TextEditingController();
}

class PublicRecipeTab {
  PublicRecipeTab() {
    this.errorText = '';
    this.isLoading = false;
    this.isLoadingMore = false;
    this.recipes = [];
    this.filteredRecipes = [];
    this.lastVisible = null;
    this.filteredLastVisible = null;
    this.canLoadMore = false;
    this.canLoadMoreFiltered = false;
    this.existsRecipe = false;
    this.existsFilteredRecipe = false;
    this.isFiltering = false;
    this.showFilteredRecipe = false;
    this.filterQuery = null;
    this.textController = TextEditingController();
  }

  String errorText = '';
  bool isLoading = false;
  bool isLoadingMore = false;
  List recipes = [];
  List filteredRecipes = [];
  QueryDocumentSnapshot lastVisible;
  QueryDocumentSnapshot filteredLastVisible;
  bool canLoadMore = false;
  bool canLoadMoreFiltered = false;
  bool existsRecipe = false;
  bool existsFilteredRecipe = false;
  bool isFiltering = false;
  Query filterQuery;
  bool showFilteredRecipe;
  TextEditingController textController = TextEditingController();
}
