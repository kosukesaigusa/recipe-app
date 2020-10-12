import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  // Future fetchSignUp(context) async {}
  //mamushi.journey@gmail.com

  String mail = '';
  String password = '';
  String confirm = ''; //パスワード（確認用）

  Future signUp() async {
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
      //firebaseAuthにユーザーを登録する
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail,
        password: password,
      );
      // Firestore に users を作成する
      await FirebaseFirestore.instance.collection('users').add(
        {
          'email': mail,
          //TODO:uerIdの指定する
          'createdAt': DateTime.now(),
        },
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
