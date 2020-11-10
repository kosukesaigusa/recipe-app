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
import 'package:recipe/domain/recipe_add.dart';

class RecipeAddModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  RecipeAdd recipeAdd = RecipeAdd();
  List<Recipe> recipes = [];
  File imageFile;
  File thumbnailImageFile;
  bool isUploading = false;
  bool willPublish = false;
  bool agreed = false;
  String errorName = '';
  String errorContent = '';
  String errorReference = '';
  bool isNameValid = false;
  bool isContentValid = false;
  bool isReferenceValid = true;

  Future fetchRecipeAdd(context) async {
    QuerySnapshot docs =
        await FirebaseFirestore.instance.collection('recipes').get();
    List<Recipe> recipes = docs.docs.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;
    notifyListeners();
  }

  Future showImagePicker() async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    File pickedImage = File(pickedFile.path);

    if (pickedImage == null) {
      return;
    }
    // 画像をアスペクト比 4:3 で 切り抜く
    File _croppedImageFile = await ImageCropper.cropImage(
      sourcePath: pickedImage.path,
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

    notifyListeners();
  }

  Future addRecipeToFirebase() async {
    // 画像が変更されている場合のみ実行する
    if (this.imageFile != null) {
      recipeAdd.imageURL = await _uploadImage();
      recipeAdd.thumbnailURL = await _uploadThumbnail();
    }

    // tokenMap を作成するための入力となる文字列のリスト
    /// レシピ名とレシピの全文を検索対象にする場合
    List _preTokenizedList = [];
    _preTokenizedList.add(recipeAdd.name);
    _preTokenizedList.add(recipeAdd.content);

    List _tokenizedList = tokenize(_preTokenizedList);
    recipeAdd.tokenMap =
        Map.fromIterable(_tokenizedList, key: (e) => e, value: (_) => true);
    print(recipeAdd.tokenMap);

    String generatedId;

    await FirebaseFirestore.instance
        .collection('users/${_auth.currentUser.uid}/recipes')
        .add(
          {
            'userId': _auth.currentUser.uid,
            'name': recipeAdd.name,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'thumbnailURL': recipeAdd.thumbnailURL,
            'thumbnailName': recipeAdd.thumbnailName,
            'imageURL': recipeAdd.imageURL,
            'imageName': recipeAdd.imageName,
            'content': recipeAdd.content,
            'reference': recipeAdd.reference,
            'tokenMap': recipeAdd.tokenMap,
            'isPublic': recipeAdd.isPublic,
          },
        )
        .then((docRef) async => {generatedId = docRef.id})
        .then((_) async => {
              await FirebaseFirestore.instance
                  .collection('users/${_auth.currentUser.uid}/recipes')
                  .doc(generatedId)
                  .update(
                {
                  'documentId': generatedId,
                },
              )
            });

    if (recipeAdd.isPublic) {
      /// みんなのレシピの ID は、public_{わたしのレシピのID} の形にする
      await FirebaseFirestore.instance
          .collection('public_recipes')
          .doc('public_$generatedId')
          .set(
        {
          'documentId': 'public_$generatedId',
          'userId': _auth.currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'name': recipeAdd.name,
          'thumbnailURL': recipeAdd.thumbnailURL,
          'thumbnailName': recipeAdd.thumbnailName,
          'imageURL': recipeAdd.imageURL,
          'imageName': recipeAdd.imageName,
          'content': recipeAdd.content,
          'reference': recipeAdd.reference,
          'tokenMap': recipeAdd.tokenMap,
          'isPublic': recipeAdd.isPublic,
        },
      );
    }

    notifyListeners();
  }

  // Firestore に画像をアップロードする
  Future<String> _uploadImage() async {
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
    String downloadURL = await _snapshot.ref.getDownloadURL();
    recipeAdd.imageName = _fileName;
    return downloadURL;
  }

  // Firestore にサムネイル用画像をアップロードする
  Future<String> _uploadThumbnail() async {
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
    String downloadURL = await _snapshot.ref.getDownloadURL();
    recipeAdd.thumbnailName = _fileName;
    return downloadURL;
  }

  void changeRecipeName(text) {
    this.recipeAdd.name = text;
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

  void changeRecipeContent(text) {
    this.recipeAdd.content = text;
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

  void changeRecipeReference(text) {
    this.recipeAdd.reference = text;
    if (text.length > 1000) {
      this.isReferenceValid = false;
      this.errorReference = '1000文字以内で入力して下さい。';
    } else {
      this.isReferenceValid = true;
      this.errorReference = '';
    }
    notifyListeners();
  }

  void tapPublishCheckbox(val) {
    this.willPublish = val;
    if (val == false) {
      this.agreed = false;
    }
    notifyListeners();
  }

  void tapAgreeCheckBox(val) {
    this.agreed = val;
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
