import 'package:flutter/material.dart';

class TopModel extends ChangeNotifier {
  int currentIndex = 1;

  Future init() async {
    notifyListeners();
  }

  void onTabTapped(int index) {
    this.currentIndex = index;
    notifyListeners();
  }
}
