import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinkAnonymousUserModel extends ChangeNotifier {
  Future fetchPasswordUpdate(context) async {}

  String mail = '';
  String password = '';
  String confirm = '';
  bool isLoading = false;

  Future linkAnonymousUser() async {
    //バリデーション
    if (mail.isEmpty) {
      throw ('メールアドレスを入力してください');
    }
    if (password.isEmpty) {
      throw ('パスワードを入力してください');
    }

    if (password.length < 8 || password.length > 20) {
      throw ('パスワードは8文字以上20文字以内です');
    }

    if (password != confirm) {
      throw ('同じパスワードを入力してください');
    }

    try {
      // ユーザー情報オブジェクト
      final credential = EmailAuthProvider.credential(
        email: mail,
        password: password,
      );
      //匿名アカウントから永久アカウントに変更する
      final result = await FirebaseAuth.instance.currentUser
          .linkWithCredential(credential);

      //FireStoreにユーザー情報をsetする
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user.uid)
          .update(
        {
          'email': mail,
        },
      );
    } catch (e) {
      _errorMessage(e.code);
    }
  }

  ///ログイン（ユーザー登録直後に叩く）
  Future login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
    } catch (e) {
      print('${e.code}: $e');
      throw (_errorMessage(e.code));
    }
  }

  ///ローディング
  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}

String _errorMessage(e) {
  switch (e) {
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力してください';
    case 'email-already-in-use':
      return 'メールアドレスはすでに別のアカウントで使用されています。';
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
