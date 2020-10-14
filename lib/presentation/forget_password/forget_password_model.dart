import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordModel extends ChangeNotifier {
  String mail = '';
  bool isLoading = false;

  Future sendResetEmail() async {
    if (mail.isEmpty) {
      throw ('メールアドレスを入力してください');
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: mail,
      );
    } catch (e) {
      print('${e.code}: $e');
      throw (_convertErrorMessage(e.code));
    }
  }

  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}

String _convertErrorMessage(eCode) {
  switch (eCode) {
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力してください';
    case 'user-not-found':
      return 'ユーザーが見つかりません';
    case 'user-disabled':
      return 'ユーザーが無効です';
    default:
      return '不明なエラーです';
  }
}
