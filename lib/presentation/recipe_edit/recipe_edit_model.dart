import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeEditModel extends ChangeNotifier {
  RecipeEditModel(this.currentRecipe) {
    this.editedRecipe = currentRecipe;
    fetchRecipe();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Recipe> recipes = [];
  File imageFile;
  File thumbnailImageFile;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isMyRecipe;
  bool isEdited = false;
  bool willPublish = false;
  bool agreed = false;
  Recipe currentRecipe;
  Recipe editedRecipe;
  String errorName = '';
  String errorContent = '';
  String errorReference = '';
  bool isNameValid = true;
  bool isContentValid = true;
  bool isReferenceValid = true;

  Future fetchRecipe() async {
    startLoading();
    DocumentSnapshot _doc;
    if (currentRecipe.isMyRecipe == true) {
      this.isMyRecipe = true;

      /// レシピのドキュメント ID が "public_" から始まる場合は、
      /// それに対応する「わたしのレシピ」を取得する
      if (currentRecipe.documentId.startsWith('public_')) {
        _doc = await FirebaseFirestore.instance
            .collection('users/${currentRecipe.userId}/recipes')
            .doc('${currentRecipe.documentId}'.replaceFirst('public_', ''))
            .get();
      } else {
        _doc = await FirebaseFirestore.instance
            .collection('users/${currentRecipe.userId}/recipes')
            .doc('${this.currentRecipe.documentId}')
            .get();
      }
    } else {
      this.isMyRecipe = false;
      _doc = await FirebaseFirestore.instance
          .collection('public_recipes')
          .doc('${currentRecipe.documentId}')
          .get();
    }

    this.currentRecipe = Recipe(_doc);
    this.currentRecipe.isMyRecipe = this.isMyRecipe;
    this.editedRecipe = Recipe(_doc);
    this.editedRecipe.isMyRecipe = this.isMyRecipe;

    endLoading();
    notifyListeners();
  }

  Future<void> showImagePicker() async {
    ImagePicker _picker = ImagePicker();
    PickedFile _pickedFile =
        await _picker.getImage(source: ImageSource.gallery);
    if (_pickedFile == null) {
      return;
    }

    File _pickedImage = File(_pickedFile.path);

    if (_pickedImage == null) {
      return;
    }
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

    // レシピ画像（W: 400, H:300 @2x）
    this.imageFile = await FlutterNativeImage.compressImage(
      _croppedImageFile.path,
      targetWidth: 400,
      targetHeight: 300,
    );

    // サムネイル用画像（W: 200, H: 30 @2x）
    this.thumbnailImageFile = await FlutterNativeImage.compressImage(
      _croppedImageFile.path,
      targetWidth: 200,
      targetHeight: 150,
    );

    this.isEdited = true;
    notifyListeners();
  }

  // レシピの更新
  Future<void> updateRecipe() async {
    startLoading();
    if (editedRecipe.name.isEmpty) {
      throw ('レシピ名を入力してください');
    }
    if (editedRecipe.content.isEmpty) {
      throw ('作り方・材料を入力してください');
    }

    /// レシピ名とレシピの全文を検索対象にする場合
    List _preTokenizedList = [];
    _preTokenizedList.add(editedRecipe.name);
    _preTokenizedList.add(editedRecipe.content);

    List _tokenizeList = tokenize(_preTokenizedList);
    editedRecipe.tokenMap =
        Map.fromIterable(_tokenizeList, key: (e) => e, value: (_) => true);
    print(editedRecipe.tokenMap);

    // 画像が変更されている場合のみ実行する
    if (this.imageFile != null) {
      if (currentRecipe.imageURL.isNotEmpty) {
        await _deleteImage();
        await _deleteThumbnail();
      }
      await _uploadImage();
      await _uploadThumbnail();
    }

    Map<String, dynamic> _myRecipeFields = {
      'documentId': this.currentRecipe.documentId,
      'userId': this._auth.currentUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'name': this.editedRecipe.name,
      'thumbnailURL': this.editedRecipe.thumbnailURL,
      'thumbnailName': this.editedRecipe.thumbnailName,
      'imageURL': this.editedRecipe.imageURL,
      'imageName': this.editedRecipe.imageName,
      'content': this.editedRecipe.content,
      'reference': this.editedRecipe.reference,
      'tokenMap': this.editedRecipe.tokenMap,
      'isPublic': this.editedRecipe.isPublic,
    };

    Map<String, dynamic> _publicRecipeFields = {
      'documentId': 'public_${this.currentRecipe.documentId}',
      'userId': this._auth.currentUser.uid,
      'name': this.editedRecipe.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'thumbnailURL': this.editedRecipe.thumbnailURL,
      'thumbnailName': this.editedRecipe.thumbnailName,
      'imageURL': this.editedRecipe.imageURL,
      'imageName': this.editedRecipe.imageName,
      'content': this.editedRecipe.content,
      'reference': this.editedRecipe.reference,
      'tokenMap': this.editedRecipe.tokenMap,
      'isPublic': this.editedRecipe.isPublic,
    };

    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WriteBatch _batch = _firestore.batch();

    DocumentReference _usersRecipeCollection = _firestore
        .collection('users/${this._auth.currentUser.uid}/recipes')
        .doc('${this.currentRecipe.documentId}');

    DocumentReference _publicRecipeCollection = _firestore
        .collection('public_recipes')
        .doc('public_${this.currentRecipe.documentId}');

    /// users/{userId}/recipes コレクションをアップデート
    _batch.update(_usersRecipeCollection, _myRecipeFields);

    /// public_recipes コレクションをアップデート
    _batch.update(_publicRecipeCollection, _publicRecipeFields);

    _batch.commit();

    endLoading();
    notifyListeners();
  }

  // Firestore に画像をアップロードする
  Future _uploadImage() async {
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
    editedRecipe.imageURL = await _snapshot.ref.getDownloadURL();
    editedRecipe.imageName = _fileName;
  }

  // Firestore にサムネイル用画像をアップロードする
  Future _uploadThumbnail() async {
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
    editedRecipe.thumbnailURL = await _snapshot.ref.getDownloadURL();
    editedRecipe.thumbnailName = _fileName;
  }

  // Firebase Storageから通常画像を削除する
  Future _deleteImage() async {
    String _image = this.currentRecipe.imageName;
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageReference _desertRef = _storage.ref().child('images/$_image');
    _desertRef.delete();
  }

  // Firebase Storageからサムネイル画像を削除する
  Future _deleteThumbnail() async {
    String _thumbnail = this.currentRecipe.thumbnailName;
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageReference _desertRef =
        _storage.ref().child('thumbnails/$_thumbnail');
    _desertRef.delete();
  }

  changeRecipeName(text) {
    this.isEdited = true;
    this.editedRecipe.name = text;
    if (text.isEmpty) {
      this.isNameValid = false;
      this.errorName = 'レシピ名を入力して下さい。';
    } else if (text.length > 30) {
      this.isNameValid = false;
      this.errorName = '30文字以内で入力して下さい。';
    } else {
      this.isNameValid = true;
      this.errorName = '';
    }
    notifyListeners();
  }

  changeRecipeContent(text) {
    this.isEdited = true;
    this.editedRecipe.content = text;
    if (text.isEmpty) {
      this.isContentValid = false;
      this.errorContent = 'レシピの内容を入力して下さい。';
    } else if (text.length > 1000) {
      this.isContentValid = false;
      this.errorContent = '1000文字以内で入力して下さい。';
    } else {
      this.isContentValid = true;
      this.errorContent = '';
    }
    notifyListeners();
  }

  changeRecipeReference(text) {
    this.isEdited = true;
    this.editedRecipe.reference = text;
    if (text.length > 1000) {
      this.isReferenceValid = false;
      this.errorReference = '1000文字以内で入力して下さい。';
    } else {
      this.isReferenceValid = true;
      this.errorReference = '';
    }
    notifyListeners();
  }

  void tapAgreeCheckBox(val) {
    this.agreed = val;
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
