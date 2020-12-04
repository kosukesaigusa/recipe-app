import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class TopModel extends ChangeNotifier {
  TopModel() {
    this.showNewestVersionDialog = false;
    this.isIOS = Platform.isIOS;
    this.isAndroid = Platform.isAndroid;
    this.iosNewestVersion = '';
    this.androidNewestVersion = '';
    this.isNewest = true;
    this.iosAppUrl = '';
    this.androidAppUrl = '';
    this.version = '';
    init();
  }

  bool showNewestVersionDialog = false;
  bool isIOS = false;
  bool isAndroid = false;
  String iosNewestVersion;
  String androidNewestVersion;
  bool isNewest = true;
  String iosAppUrl;
  String androidAppUrl;
  PackageInfo packageInfo;
  String version;

  Future<void> init() async {
    DocumentSnapshot _doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('app_url')
        .get();
    this.iosAppUrl = _doc.data()['iosUrl'];
    this.androidAppUrl = _doc.data()['androidUrl'];
  }

  void checkAppVersion() {
    Stream<DocumentSnapshot> _documentSnapshot = FirebaseFirestore.instance
        .collection('settings')
        .doc('version')
        .snapshots();

    /// settings/version ドキュメントの変更を監視して実行
    _documentSnapshot.listen((snapshot) async {
      // 現在のバージョン
      this.packageInfo = await PackageInfo.fromPlatform();
      this.version = packageInfo.version;
      print('---');
      print('version: ${this.version}');

      // 最新のバージョンを確認
      if (this.isIOS) {
        this.iosNewestVersion = snapshot.data()['ios_newest_version'];
        print('Newest version: ${this.iosNewestVersion}');
        print('---');
        this.isNewest = this.version == this.iosNewestVersion;
        this.showNewestVersionDialog =
            snapshot.data()['showNewestVersionDialog'];
      } else if (this.isAndroid) {
        this.androidNewestVersion = snapshot.data()['android_newest_version'];
        print('Newest version: ${this.androidNewestVersion}');
        print('---');
        this.isNewest = this.version == this.androidNewestVersion;
        this.showNewestVersionDialog =
            snapshot.data()['showNewestVersionDialog'];
      }

      notifyListeners();
    });
  }
}
