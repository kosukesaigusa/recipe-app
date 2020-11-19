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
import 'package:recipe/domain/recipe_edit.dart';

class RecipeEditModel extends ChangeNotifier {
  RecipeEditModel(Recipe _currentRecipe) {
    this.currentRecipe = _currentRecipe;
    this.editedRecipe = RecipeEdit();
    this.existsPublishedDocument = false;
    this.imageFile = null;
    this.thumbnailImageFile = null;
    this.isLoading = false;
    this.isSubmitting = false;
    init();
  }

  Recipe currentRecipe;
  RecipeEdit editedRecipe;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool existsPublishedDocument;
  File imageFile;
  File thumbnailImageFile;
  bool isLoading;
  bool isSubmitting;

  Future init() async {
    startLoading();

    // editedRecipe インスタンスの各フィールドの初期化
    this.editedRecipe.name = this.currentRecipe.name;
    this.editedRecipe.thumbnailURL = this.currentRecipe.thumbnailURL;
    this.editedRecipe.thumbnailName = this.currentRecipe.thumbnailName;
    this.editedRecipe.imageURL = this.currentRecipe.imageURL;
    this.editedRecipe.imageName = this.currentRecipe.imageName;
    this.editedRecipe.content = this.currentRecipe.content;
    this.editedRecipe.reference = this.currentRecipe.reference;

    // 当該レシピが既に public_recipes コレクションに存在するかどうか確認
    DocumentSnapshot _snap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .doc('public_${this.currentRecipe.documentId}')
        .get();
    this.existsPublishedDocument = _snap.exists;

    endLoading();
    notifyListeners();
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

      // サムネイル用画像（W: 200, H: 30 @2x）をインスタンス変数に保存
      this.thumbnailImageFile = await FlutterNativeImage.compressImage(
        _croppedImageFile.path,
        targetWidth: 200,
        targetHeight: 150,
      );
    } catch (e) {
      return;
    }

    this.editedRecipe.isEdited = true;
    notifyListeners();
  }

  // レシピの更新
  Future<void> updateRecipe() async {
    startLoading();
    if (editedRecipe.name.isEmpty) {
      throw ('レシピ名を入力してください。');
    }
    if (editedRecipe.content.isEmpty) {
      throw ('作り方・材料を入力してください。');
    }

    /// content, reference から不要な空行を取り除く
    this.editedRecipe.content =
        removeUnnecessaryBlankLines(this.editedRecipe.content);
    this.editedRecipe.reference =
        removeUnnecessaryBlankLines(this.editedRecipe.reference);

    /// tokenMap を作成するための入力となる文字列のリスト
    List _preTokenizedList = [];
    _preTokenizedList.add(this.editedRecipe.name);
    _preTokenizedList.add(this.editedRecipe.content);

    List _tokenizeList = tokenize(_preTokenizedList);
    this.editedRecipe.tokenMap =
        Map.fromIterable(_tokenizeList, key: (e) => e, value: (_) => true);
    print(this.editedRecipe.tokenMap);

    // 画像が変更されている場合のみ、既存の画像を削除して、新しいものをアップロード
    if (this.imageFile != null) {
      if (this.currentRecipe.imageURL.isNotEmpty) {
        await _deleteImage();
      } else if (this.currentRecipe.thumbnailURL.isNotEmpty) {
        await _deleteThumbnail();
      }
      await _uploadImage();
      await _uploadThumbnail();
    }

    Map<String, dynamic> _updateRecipeFields = {
      'updatedAt': FieldValue.serverTimestamp(),
      'name': this.editedRecipe.name,
      'thumbnailURL': this.editedRecipe.thumbnailURL,
      'thumbnailName': this.editedRecipe.thumbnailName,
      'imageURL': this.editedRecipe.imageURL,
      'imageName': this.editedRecipe.imageName,
      'content': this.editedRecipe.content,
      'reference': this.editedRecipe.reference,
      'tokenMap': this.editedRecipe.tokenMap,
      'isPublic': this.editedRecipe.willPublish,
    };

    Map<String, dynamic> _setRecipeFields = {
      // set の方でだけ送信するフィールド（3つ）
      'userId': this._auth.currentUser.uid,
      'documentId': 'public_${this.currentRecipe.documentId}',
      'createdAt': FieldValue.serverTimestamp(),
      // update の方と共通のフィールド
      'updatedAt': FieldValue.serverTimestamp(),
      'name': this.editedRecipe.name,
      'thumbnailURL': this.editedRecipe.thumbnailURL,
      'thumbnailName': this.editedRecipe.thumbnailName,
      'imageURL': this.editedRecipe.imageURL,
      'imageName': this.editedRecipe.imageName,
      'content': this.editedRecipe.content,
      'reference': this.editedRecipe.reference,
      'tokenMap': this.editedRecipe.tokenMap,
      'isPublic': this.editedRecipe.willPublish,
    };

    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WriteBatch _batch = _firestore.batch();

    DocumentReference _usersRecipeCollection = _firestore
        .collection('users/${this._auth.currentUser.uid}/recipes')
        .doc('${this.currentRecipe.documentId}');

    DocumentReference _publicRecipeCollection = _firestore
        .collection('public_recipes')
        .doc('public_${this.currentRecipe.documentId}');

    /// users/{userId}/recipes コレクションを update or set
    _batch.update(_usersRecipeCollection, _updateRecipeFields);

    /// public_recipes コレクションを update or set
    if (this.existsPublishedDocument) {
      // update: 当該レシピが一度は公開されたことがある場合
      _batch.update(_publicRecipeCollection, _updateRecipeFields);
    } else if (!this.existsPublishedDocument && this.editedRecipe.willPublish) {
      // set: まだ当該レシピが、今回はじめて公開される場合
      _batch.set(_publicRecipeCollection, _setRecipeFields);
    }

    await _batch.commit();

    endLoading();
    notifyListeners();
  }

  // Firestore Storage  に画像をアップロードして 画像 URL と画像名を得る
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
    this.editedRecipe.imageURL = await _snapshot.ref.getDownloadURL();
    this.editedRecipe.imageName = _fileName;
  }

  // Firestore Storage にサムネイル用画像をアップロードして 画像 URL と画像名を得る
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
    this.editedRecipe.thumbnailURL = await _snapshot.ref.getDownloadURL();
    this.editedRecipe.thumbnailName = _fileName;
  }

  // Firebase Storage から通常画像を削除する
  Future<void> _deleteImage() async {
    String _image = this.currentRecipe.imageName;
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageReference _desertRef = _storage.ref().child('images/$_image');
    _desertRef.delete();
  }

  // Firebase Storage からサムネイル画像を削除する
  Future<void> _deleteThumbnail() async {
    String _thumbnail = this.currentRecipe.thumbnailName;
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageReference _desertRef =
        _storage.ref().child('thumbnails/$_thumbnail');
    _desertRef.delete();
  }

  Future<void> deleteRecipe() async {
    /// 画像の削除
    await _deleteImage();
    await _deleteThumbnail();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    WriteBatch _batch = _firestore.batch();

    DocumentReference _usersRecipeCollection = _firestore
        .collection('users/${this._auth.currentUser.uid}/recipes')
        .doc('${this.currentRecipe.documentId}');

    DocumentReference _publicRecipeCollection = _firestore
        .collection('public_recipes')
        .doc('public_${this.currentRecipe.documentId}');

    /// users/{userId}/recipes のレシピを削除
    _batch.delete(_usersRecipeCollection);

    /// public_recipes のレシピを削除
    _batch.delete(_publicRecipeCollection);

    _batch.commit();

    endLoading();
    notifyListeners();
  }

  void changeRecipeName(text) {
    this.editedRecipe.isEdited = true;
    this.editedRecipe.name = text;
    if (text.isEmpty) {
      this.editedRecipe.isNameValid = false;
      this.editedRecipe.errorName = 'レシピ名を入力して下さい。';
    } else if (text.length > 30) {
      this.editedRecipe.isNameValid = false;
      this.editedRecipe.errorName = '30文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.editedRecipe.isNameValid = true;
      this.editedRecipe.errorName = '';
    }
    notifyListeners();
  }

  void changeRecipeContent(text) {
    this.editedRecipe.isEdited = true;
    this.editedRecipe.content = text;
    if (text.isEmpty) {
      this.editedRecipe.isContentValid = false;
      this.editedRecipe.errorContent = 'レシピの内容を入力して下さい。';
    } else if (text.length > 1000) {
      this.editedRecipe.isContentValid = false;
      this.editedRecipe.errorContent =
          '1000文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.editedRecipe.isContentValid = true;
      this.editedRecipe.errorContent = '';
    }
    notifyListeners();
  }

  void changeRecipeReference(text) {
    this.editedRecipe.isEdited = true;
    this.editedRecipe.reference = text;
    if (text.length > 1000) {
      this.editedRecipe.isReferenceValid = false;
      this.editedRecipe.errorReference =
          '1000文字以内で入力して下さい（現在 ${text.length} 文字）。';
    } else {
      this.editedRecipe.isReferenceValid = true;
      this.editedRecipe.errorReference = '';
    }
    notifyListeners();
  }

  void focusRecipeName(val) {
    this.editedRecipe.isNameFocused = val;
    notifyListeners();
  }

  void focusRecipeContent(val) {
    this.editedRecipe.isContentFocused = val;
    notifyListeners();
  }

  void focusRecipeReference(val) {
    this.editedRecipe.isReferenceFocused = val;
    notifyListeners();
  }

  void tapAgreeCheckBox(val) {
    this.editedRecipe.agreeGuideline = val;
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
