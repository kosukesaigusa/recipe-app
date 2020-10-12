import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInModel extends ChangeNotifier {
  // Future fetchSignIn(context) async {}

  String mail = '';
  String password = '';

  Future login() async {
    if (mail.isEmpty) {
      throw ('メールアドレスを入力してください');
    }
    if (password.isEmpty) {
      throw ('パスワードを入力してください');
    }

    if (password.length < 8 || password.length > 20) {
      throw ('パスワードは8文字以上20文字以内です');
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
    } catch (e) {
      _errorMessage(e.code);
    }
  }
}

String _errorMessage(e) {
  switch (e) {
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力してください';
    case 'email-already-in-use':
      return '既に登録済みです';
    default:
      return '不明なエラーです';
  }
}
