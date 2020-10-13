import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordUpdateModel extends ChangeNotifier {
  Future fetchPasswordUpdate(context) async {}

  String password = '';
  String newPassword = '';
  String confirm = '';

  Future updatePassword() async {
    //バリデーション
    if (password.isEmpty) {
      throw ('現在のパスワードを入力してください');
    }
    //TODO:現在のパスワードが正しいものか確認

    if (newPassword.isEmpty) {
      throw ('新しいパスワードを入力してください');
    }
    if (confirm.isEmpty) {
      throw ('確認用パスワードを入力してください');
    }
    if (newPassword.length < 8 || newPassword.length > 20) {
      throw ('パスワードは8文字以上20文字以内です');
    }
    if (newPassword != confirm) {
      throw ('新しいパスワードの入力内容が一致していません');
    }

    try {
      // パスワードをupdateする
      final user = FirebaseAuth.instance.currentUser;
      await user.updatePassword(newPassword);
    } catch (e) {
      _errorMessage(e.code);
    }
  }
}

String _errorMessage(e) {
  switch (e) {
    case 'user-not-found':
      return 'ユーザーが見つかりません';
    case 'user-disabled':
      return 'ユーザーが無効です';
    default:
      return '不明なエラーです';
  }
}
