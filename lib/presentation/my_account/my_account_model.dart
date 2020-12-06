import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:recipe/common/convert_error_message.dart';

class MyAccountModel extends ChangeNotifier {
  bool isLoading;
  bool isSubmitting;
  FirebaseAuth auth;
  String mail;
  String displayName;
  PackageInfo packageInfo;
  String version;
  File imageFile;
  String iconURL;
  String iconName;
  int recipeCount;
  int publicRecipeCount;

  MyAccountModel() {
    this.auth = FirebaseAuth.instance;
    this.isLoading = false;
    this.isSubmitting = false;
    this.mail = this.auth.currentUser.email;
    this.version = '';
    init();
    notifyListeners();
  }

  Future<void> init() async {
    startLoading();
    this.packageInfo = await PackageInfo.fromPlatform();
    this.version = packageInfo.version;

    DocumentSnapshot _userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('${this.auth.currentUser.uid}')
        .get();
    this.displayName = _userDoc.data()['displayName'];
    this.iconURL = _userDoc.data()['iconURL'];
    this.iconName = _userDoc.data()['iconName'];
    this.recipeCount = _userDoc.data()['recipeCount'];
    this.publicRecipeCount = _userDoc.data()['publicRecipeCount'];

    notifyListeners();
    endLoading();
  }

  Future<void> fetchMyAccount() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    this.mail = firebaseUser.email;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('${e.code}: $e');
      throw (convertErrorMessage(e.code));
    }
  }

  Future<void> showImagePicker() async {
    ImagePicker _picker = ImagePicker();

    try {
      PickedFile _pickedFile =
          await _picker.getImage(source: ImageSource.gallery);

      // 選択した画像ファイルのパスを保存
      File _pickedImage = File(_pickedFile.path);

      // 画像をアスペクト比 1:1 で 切り抜く
      File _croppedImageFile = await ImageCropper.cropImage(
        cropStyle: CropStyle.circle,
        sourcePath: _pickedImage.path,
        maxHeight: 200,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 10,
        iosUiSettings: IOSUiSettings(
          title: '編集',
        ),
      );

      // ユーザー画像（W: 200, H:200 @2x）をインスタンス変数に保存
      this.imageFile = await FlutterNativeImage.compressImage(
        _croppedImageFile.path,
        targetWidth: 200,
        targetHeight: 200,
      );
    } catch (e) {
      return;
    }

    await updateIcon();

    notifyListeners();
  }

  Future<void> updateIcon() async {
    // 画像が変更されていない場合は処理を出る
    if (this.imageFile == null) {
      print('画像が変わってないから出たよ');
      return;
    }

    startSubmitting();

    // Firebase Storage にアイコン画像を保存し、URL を取得する
    String _newIconName = "icon_" +
        DateTime.now().toString() +
        "_" +
        this.auth.currentUser.uid +
        '.jpg';
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('users/${this.auth.currentUser.uid}/icons/' + _newIconName)
        .putFile(this.imageFile)
        .onComplete;
    String _newIconURL = await _snapshot.ref.getDownloadURL();

    // Firestore のユーザー情報を更新する
    await FirebaseFirestore.instance
        .collection('users/')
        .doc('${this.auth.currentUser.uid}')
        .update(
      {
        'iconURL': _newIconURL,
        'iconName': _newIconName,
      },
    );

    // 既存のアイコンを Storage から削除する
    if (this.iconURL != null) {
      String _oldIcon = this.iconName;
      StorageReference _iconRef = _storage
          .ref()
          .child('users/${this.auth.currentUser.uid}/icons/$_oldIcon');

      try {
        await _iconRef.delete();
        print('アイコン画像を削除した：users/${this.auth.currentUser.uid}/icons/$_oldIcon');
      } catch (e) {
        print(
            'アイコン画像を削除できなかった：users/${this.auth.currentUser.uid}/icons/$_oldIcon');
        _iconRef = _storage.ref().child('icons/$_oldIcon');
        try {
          await _iconRef.delete();
          print('アイコン画像を削除した：images/$_oldIcon');
        } catch (e) {
          print('アイコン画像を削除できなかった：images/$_oldIcon');
        }
      }
    }

    await init();

    endSubmitting();
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

  void startSubmitting() {
    this.isSubmitting = true;
    notifyListeners();
  }

  void endSubmitting() {
    this.isSubmitting = false;
    notifyListeners();
  }
}
