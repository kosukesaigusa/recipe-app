import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class TopModel extends ChangeNotifier {
  TopModel() {
    this.newestVersion = '';
    this.isNewest = true;
    this.version = '';
  }

  String newestVersion;
  bool isNewest;
  PackageInfo packageInfo;
  String version;

  void checkAppVersion() {
    Stream<DocumentSnapshot> _documentSnapshot = FirebaseFirestore.instance
        .collection('settings')
        .doc('version')
        .snapshots();
    _documentSnapshot.listen((snapshot) async {
      // 現在のバージョン
      this.packageInfo = await PackageInfo.fromPlatform();
      this.version = packageInfo.version;
      print('---');
      print('version: ${this.version}');

      // 最新のバージョン
      this.newestVersion = snapshot.data()['newest_version'];
      print('Newest version: ${this.newestVersion}');
      print('---');

      this.isNewest = this.version == this.newestVersion;

      notifyListeners();
    });
  }
}
