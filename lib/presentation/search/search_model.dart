import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchModel extends ChangeNotifier {
  String firestoreEnv;
  bool isLoading;
  int recipeTabIndex = 0;

  Future fetchSearch(context) async {
    startLoading();
    DocumentSnapshot docFirestoreEnv = await FirebaseFirestore.instance
        .collection('test')
        .doc('firestore_environment')
        .get();
    this.firestoreEnv = docFirestoreEnv.data()['firestore_environment'];
    endLoading();
    notifyListeners();
  }

  void onRecipeTabTapped(int index) {
    this.recipeTabIndex = index;
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
  }

  void endLoading() {
    this.isLoading = false;
  }
}
