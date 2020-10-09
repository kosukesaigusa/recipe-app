import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe/domain/user_state.dart';

class AppModel {
  // ignore: close_sinks
  final _userStateStreamController = StreamController<UserState>();
  Stream<UserState> get userState => _userStateStreamController.stream;

  UserState _state;

  // コンストラクタ
  AppModel() {
    _init();
  }

  // 初期化処理
  Future _init() async {
    // packageの初期化処理
    await Firebase.initializeApp();

    // ログイン状態の変化を監視し、変更があればUserStateをstreamで通知する
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      UserState state = UserState.signedOut;
      final user = await _fetchUser(firebaseUser);
      if (user != null) {
        state = UserState.signedIn;
      }

      // 前回と同じ通知はしない
      if (_state == state) {
        return;
      }
      _state = state;

      // noLogin の場合すぐに SplashPage が閉じてしまうので少し待つ
      if (_state == UserState.signedOut) {
        await Future.delayed(Duration(seconds: 2));
      }
      _userStateStreamController.sink.add(_state);
    });
  }

  // ユーザを取得する
  Future<User> _fetchUser(User firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }
    final docUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!docUser.exists) {
      return null;
    }
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User user = _auth.currentUser;
    return user;
  }
}
