import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/convert_error_message.dart';

class SignUpModel extends ChangeNotifier {
  SignUpModel() {
    this.agreeGuideline = false;
    this.showingDialog = false;
    this.mail = '';
    this.password = '';
    this.confirm = '';
    this.errorMail = '';
    this.errorPassword = '';
    this.errorConfirm = '';
    this.isLoading = false;
    this.isMailValid = false;
    this.isPasswordValid = false;
    this.isConfirmValid = false;
    this.userCredential = null;
    this.isGuestAllowed = false;
  }

  bool agreeGuideline;
  bool showingDialog;
  String mail;
  String password;
  String confirm;
  String errorMail;
  String errorPassword;
  String errorConfirm;
  bool isLoading;
  bool isMailValid;
  bool isPasswordValid;
  bool isConfirmValid;
  UserCredential userCredential;
  bool isGuestAllowed;

  Future<void> init() async {
    DocumentSnapshot _doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('guest_mode')
        .get();
    this.isGuestAllowed = _doc.data()['guest_allowed'];
    notifyListeners();
  }

  Future signUp() async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }

    /// 入力されたメール, パスワードで UserCredential を作成
    try {
      this.userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: this.mail,
        password: this.password,
      );
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    /// UserCredential の null チェック
    if (this.userCredential == null) {
      print('UserCredential が見つからないエラー');
      throw ('エラーが発生しました。');
    }

    /// users コレクションにユーザーデータを保存
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      WriteBatch _batch = _firestore.batch();

      // user ドキュメント
      DocumentReference _userDoc =
          _firestore.collection('users').doc(this.userCredential.user.uid);

      // user info ドキュメント
      DocumentReference _userEmailDoc = _firestore
          .collection('users')
          .doc(this.userCredential.user.uid)
          .collection('user_info')
          .doc('email');

      // user ドキュメントのフィールド
      Map<String, dynamic> _userFields = {
        'userId': this.userCredential.user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': 'シンプルなレシピユーザー',
        'iconName': null,
        'iconURL': null,
        'recipeCount': 0,
        'publicRecipeCount': 0,
      };

      // user info ドキュメントのフィールド
      Map<String, dynamic> _userInfoFields = {
        'email': this.userCredential.user.email,
      };

      _batch.set(_userDoc, _userFields);
      _batch.set(_userEmailDoc, _userInfoFields);
      await _batch.commit();
    } catch (e) {
      print('ユーザードキュメントの作成中にエラー');
      print(e.toString());
      throw ('エラーが発生しました。');
    }
  }

  Future signInAnonymously() async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInAnonymously();

      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      WriteBatch _batch = _firestore.batch();

      // user ドキュメント
      DocumentReference _userDoc =
          _firestore.collection('users').doc(result.user.uid);

      // user info ドキュメント
      DocumentReference _userEmailDoc = _firestore
          .collection('users')
          .doc(result.user.uid)
          .collection('user_info')
          .doc('email');

      // user ドキュメントのフィールド
      Map<String, dynamic> _userFields = {
        'userId': result.user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': 'ゲスト',
        'iconName': null,
        'iconURL': null,
        'recipeCount': 0,
        'publicRecipeCount': 0,
      };

      _batch.set(_userDoc, _userFields);
      _batch.set(_userEmailDoc, {'email': null});
      await _batch.commit();
    } catch (e) {
      print('匿名サインインおよびユーザードキュメントの作成の処理でエラーが発生');
      print(e.toString());
      throw ('エラーが発生しました。');
    }
  }

  void changeMail(text) {
    this.mail = text.trim();
    if (text.length == 0) {
      this.isMailValid = false;
      this.errorMail = 'メールアドレスを入力して下さい。';
    } else {
      this.isMailValid = true;
      this.errorMail = '';
    }
    notifyListeners();
  }

  void changePassword(text) {
    this.password = text;
    if (text.length == 0) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isPasswordValid = true;
      this.errorPassword = '';
    }
    notifyListeners();
  }

  void changeConfirm(text) {
    this.confirm = text;
    if (text.length == 0) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードを再入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードは8文字以上20文字以内です。';
    } else {
      isConfirmValid = true;
      this.errorConfirm = '';
    }
    notifyListeners();
  }

  void tapAgreeCheckBox(val) {
    this.agreeGuideline = val;
    notifyListeners();
  }

  void showDialog() {
    this.showingDialog = true;
    notifyListeners();
  }

  void hideDialog() {
    this.showingDialog = false;
    notifyListeners();
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
