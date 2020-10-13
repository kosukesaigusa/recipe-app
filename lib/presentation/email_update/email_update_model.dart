import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailUpdateModel extends ChangeNotifier {
  // Future fetchEmailUpdate(context) async {}
  String newMail = '';
  String confirmMail = '';
  String password = '';
  bool isLoading = false;

  startLoading() async {
    isLoading = true;
    notifyListeners();
  }

  endLoading() async {
    isLoading = false;
    notifyListeners();
  }

  //メールアドレスのアップデート
  Future updateMail() async {
    //バリデーション
    if (newMail.isEmpty) {
      throw ("新しいメールアドレスを入力してください");
    }
    if (confirmMail.isEmpty) {
      throw ("確認用のメールアドレスを入力してください");
    }
    if (password.isEmpty) {
      throw ("パスワードを入力してください");
    }
    if (password.length < 8 || password.length > 20) {
      throw ('パスワードは8文字以上20文字以内です');
    }
    if (newMail != confirmMail) {
      throw ("新しいメールアドレスと確認用のメールアドレスが一致しません。");
    }

    try {
      //メールアドレスのアップデートの処理

      final user = FirebaseAuth.instance.currentUser;
      await user.updateEmail(newMail);
    } catch (e) {
      _errorMessage(e.toString());
    }
  }
}

String _errorMessage(e) {
  switch (e) {
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力してください';
    case 'wrong-password':
      return 'パスワードが間違っています';
    case 'user-not-found':
      return 'ユーザーが見つかりません';
    case 'user-disabled':
      return 'ユーザーが無効です';
    default:
      return '不明なエラーです';
  }
}
