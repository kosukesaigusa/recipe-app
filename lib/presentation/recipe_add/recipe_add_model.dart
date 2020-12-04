import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe_add.dart';

class RecipeAddModel extends ChangeNotifier {
  RecipeAdd recipeAdd;
  FirebaseAuth _auth;
  File imageFile;
  File thumbnailImageFile;
  bool isUploading;

  RecipeAddModel() {
    this.recipeAdd = RecipeAdd();
    this._auth = FirebaseAuth.instance;
    this.imageFile = null;
    this.thumbnailImageFile = null;
    this.isUploading = false;
  }

  Future<void> showImagePicker() async {
    ImagePicker _picker = ImagePicker();

    try {
      PickedFile _pickedFile =
          await _picker.getImage(source: ImageSource.gallery);

      // 選択した画像ファイルのパスを保存
      File _pickedImage = File(_pickedFile.path);

      // 画像をアスペクト比 4:3 で 切り抜く
      File _croppedImageFile = await ImageCropper.cropImage(
        sourcePath: _pickedImage.path,
        maxHeight: 150,
        aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 10,
        iosUiSettings: IOSUiSettings(
          title: '編集',
        ),
      );

      // レシピ画像（W: 400, H:300 @2x）をインスタンス変数に保存
      this.imageFile = await FlutterNativeImage.compressImage(
        _croppedImageFile.path,
        targetWidth: 400,
        targetHeight: 300,
      );

      // サムネイル用画像（W: 200, H: 30 @2x）を
      this.thumbnailImageFile = await FlutterNativeImage.compressImage(
        _croppedImageFile.path,
        targetWidth: 200,
        targetHeight: 150,
      );

      print('圧縮のあと');
    } catch (e) {
      print('Image Picker から画像の圧縮の過程でエラーが発生');
      print(e.toString());
      return;
    }

    notifyListeners();
  }

  Future<void> addRecipeToFirebase() async {
    // 画像が追加されている場合のみ実行
    if (this.imageFile != null) {
      await _uploadImage();
    }
    // サムネイル用画像が追加されている場合のみ実行
    if (this.thumbnailImageFile != null) {
      await _uploadThumbnail();
    }

    /// content, reference から不要な空行を取り除く
    this.recipeAdd.content =
        removeUnnecessaryBlankLines(this.recipeAdd.content);
    this.recipeAdd.reference =
        removeUnnecessaryBlankLines(this.recipeAdd.reference);

    /// tokenMap を作成するための入力となる文字列のリスト
    List _preTokenizedList = [];
    _preTokenizedList.add(this.recipeAdd.name);
    _preTokenizedList.add(this.recipeAdd.content);

    List _tokenizedList = tokenize(_preTokenizedList);
    this.recipeAdd.tokenMap =
        Map.fromIterable(_tokenizedList, key: (e) => e, value: (_) => true);
    print(this.recipeAdd.tokenMap);

    /// わたしのレシピ, みんなのレシピ, 投稿したレシピ数, 公開したレシピ数
    /// の追加・更新をバッチで処理
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WriteBatch _batch = _firestore.batch();

    // レシピのドキュメント ID を空のドキュメントを指定して生成する
    String _generatedId = _firestore
        .collection('users/${this._auth.currentUser.uid}/recipes')
        .doc()
        .id;

    // 現在の投稿したレシピ数, 公開したレシピ数
    DocumentReference _myUserDoc =
        _firestore.collection('users').doc(this._auth.currentUser.uid);
    DocumentSnapshot _snap = await _myUserDoc.get();
    int _recipeCount = _snap.data()['recipeCount'];
    int _publicRecipeCount = _snap.data()['publicRecipeCount'];

    // 追加するわたしのレシピのドキュメントレファレンス
    DocumentReference _myRecipeDoc = _firestore
        .collection('users/${this._auth.currentUser.uid}/recipes')
        .doc(_generatedId);

    // users/{userId}/recipes コレクションにレシピデータを set
    _batch.set(_myRecipeDoc, {
      'documentId': _generatedId,
      'userId': this._auth.currentUser.uid,
      'name': this.recipeAdd.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'thumbnailURL': this.recipeAdd.thumbnailURL,
      'thumbnailName': this.recipeAdd.thumbnailName,
      'imageURL': this.recipeAdd.imageURL,
      'imageName': this.recipeAdd.imageName,
      'content': this.recipeAdd.content,
      'reference': this.recipeAdd.reference,
      'tokenMap': this.recipeAdd.tokenMap,
      'isPublic': this.recipeAdd.willPublish,
    });

    // 投稿したレシピ数を 1 増やす
    _batch.update(_myUserDoc, {'recipeCount': _recipeCount + 1});

    // 公開する場合は public_recipes コレクションにレシピデータを set
    if (this.recipeAdd.willPublish) {
      // みんなのレシピの ID は、public_{わたしのレシピのID} の形にする
      DocumentReference _publicRecipeDoc =
          _firestore.collection('public_recipes').doc('public_$_generatedId');

      _batch.set(_publicRecipeDoc, {
        'documentId': 'public_$_generatedId',
        'userId': this._auth.currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'name': this.recipeAdd.name,
        'thumbnailURL': this.recipeAdd.thumbnailURL,
        'thumbnailName': this.recipeAdd.thumbnailName,
        'imageURL': this.recipeAdd.imageURL,
        'imageName': this.recipeAdd.imageName,
        'content': this.recipeAdd.content,
        'reference': this.recipeAdd.reference,
        'tokenMap': this.recipeAdd.tokenMap,
        'isPublic': this.recipeAdd.willPublish,
      });

      // 公開したレシピ数を 1 増やす
      _batch.update(_myUserDoc, {'publicRecipeCount': _publicRecipeCount + 1});
    }

    await _batch.commit();

    notifyListeners();
  }

  // Firestore に画像をアップロードしてその URL を返す
  Future<void> _uploadImage() async {
    String _fileName = "image_" +
        DateTime.now().toString() +
        "_" +
        _auth.currentUser.uid +
        '.jpg';
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('images/' + _fileName)
        .putFile(this.imageFile)
        .onComplete;
    this.recipeAdd.imageURL = await _snapshot.ref.getDownloadURL();
    this.recipeAdd.imageName = _fileName;
  }

  // Firestore にサムネイル用画像をアップロードしてその URL を返す
  Future<void> _uploadThumbnail() async {
    String _fileName = "thumbnail_" +
        DateTime.now().toString() +
        "_" +
        _auth.currentUser.uid +
        '.jpg';
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('thumbnails/' + _fileName)
        .putFile(this.thumbnailImageFile)
        .onComplete;
    this.recipeAdd.thumbnailURL = await _snapshot.ref.getDownloadURL();
    this.recipeAdd.thumbnailName = _fileName;
  }

  void changeRecipeName(text) {
    this.recipeAdd.name = text;
    if (text.isEmpty) {
      this.recipeAdd.isNameValid = false;
      this.recipeAdd.errorName = 'レシピ名を入力して下さい。';
    } else if (text.length > 30) {
      this.recipeAdd.isNameValid = false;
      this.recipeAdd.errorName = '30 文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.recipeAdd.isNameValid = true;
      this.recipeAdd.errorName = '';
    }
    notifyListeners();
  }

  void changeRecipeContent(text) {
    this.recipeAdd.content = text;
    if (text.isEmpty) {
      this.recipeAdd.isContentValid = false;
      this.recipeAdd.errorContent = 'レシピの内容を入力して下さい。';
    } else if (text.length > 1000) {
      this.recipeAdd.isContentValid = false;
      this.recipeAdd.errorContent = '1000 文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.recipeAdd.isContentValid = true;
      this.recipeAdd.errorContent = '';
    }
    notifyListeners();
  }

  void changeRecipeReference(text) {
    this.recipeAdd.reference = text;
    if (text.length > 1000) {
      this.recipeAdd.isReferenceValid = false;
      this.recipeAdd.errorReference =
          '1000 文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.recipeAdd.isReferenceValid = true;
      this.recipeAdd.errorReference = '';
    }
    notifyListeners();
  }

  void focusRecipeName(val) {
    this.recipeAdd.isNameFocused = val;
    notifyListeners();
  }

  void focusRecipeContent(val) {
    this.recipeAdd.isContentFocused = val;
    notifyListeners();
  }

  void focusRecipeReference(val) {
    this.recipeAdd.isReferenceFocused = val;
    notifyListeners();
  }

  void tapPublishCheckbox(val) {
    this.recipeAdd.willPublish = val;
    if (val == false) {
      this.recipeAdd.agreeGuideline = false;
    }
    notifyListeners();
  }

  void tapAgreeCheckBox(val) {
    this.recipeAdd.agreeGuideline = val;
    notifyListeners();
  }

  void startLoading() {
    this.isUploading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isUploading = false;
    notifyListeners();
  }
}
