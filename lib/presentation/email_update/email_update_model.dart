import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailUpdateModel extends ChangeNotifier {
  // Future fetchEmailUpdate(context) async {}
  //kr07031321@gmail.com
  //hogehogehoge27@gmail.com
  final FirebaseAuth auth = FirebaseAuth.instance;

  String newMail;
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
  Future<void> updateMail() async {
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
      final user = auth.currentUser;
      try {
        //認証情報の作成
        EmailAuthCredential emailAuthCredential = EmailAuthProvider.credential(
          email: user.email,
          password: password,
        );
        //再認証(再認証しないとuser-mismatchとエラーが出て認証情報が更新されず後にやるupdateEmailがupdateされずに進むため回避するには再認証して認証情報を最新のものにしてあげる必要がある)
        await user.reauthenticateWithCredential(emailAuthCredential);
      } catch (e) {
        print(e.toString());
        throw (e.toString());
      }
      //メールアドレス更新
      await user.updateEmail(newMail);
      //確認用のメール送信
      await user.sendEmailVerification();
      //Firestoreのemailを更新
      //Firestoreのドキュメント取得
      final updateDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      //Firestoreの登録済みのアドレス更新と更新日時更新
      await updateDoc.update({
        'email': newMail,
        'update_at': Timestamp.now(),
      });
    } catch (e) {
      print(e.code);
      throw (_errorMessage(e.code));
    }
  }
}

String _errorMessage(e) {
  switch (e) {
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力してください';
    case 'email-already-in-use':
      return 'そのメールアドレスは、すでに使用されています';
    case 'too-many-requests':
      return 'しばらく待ってからお試し下さい';
    case 'wrong-password':
      return 'パスワードが間違っています';
    case 'user-not-found':
      return 'ユーザーが見つかりません';
    case 'user-disabled':
      return 'ユーザーが無効です';
    case 'requires-recent-login':
      return '再度認証が必要です';
    default:
      return '不明なエラーです';
  }
}
