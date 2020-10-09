import 'package:flutter/material.dart';

class MenuModel extends ChangeNotifier {
  List items;
  List leadingLists;

  void fetchMenu(context) {
    this.items = ['マイページ', 'お問い合わせ'];
    this.leadingLists = [Icons.person, Icons.mail_outline];
    notifyListeners();
  }
}
