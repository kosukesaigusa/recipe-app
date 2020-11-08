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
    this.editRecipe = currentRecipe;
    fetchRecipe();
    changeRecipeName(editRecipe.name);
    changeRecipeContent(editRecipe.content);
    changeRecipeReference(editRecipe.reference);
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Recipe> recipes = [];
  File imageFile;
  File thumbnailImageFile;
  bool isUploading = false;
  bool isMyRecipe;
  bool isEdit = false;
  String tmp;
  String documentId;
  Recipe currentRecipe;
  Recipe editRecipe;
  Map<String, dynamic> recipeUpdate;
  Map<String, dynamic> recipeAdd;
  String errorName = '';
  String errorContent = '';
  String errorReference = '';
  bool isNameValid = false;
  bool isContentValid = false;
  bool isReferenceValid = true;

  Future fetchRecipe() async {
    startLoading();
    DocumentSnapshot doc;
    if (currentRecipe.isMyRecipe == true) {
      this.isMyRecipe = true;

      /// レシピのドキュメント ID が "public_" から始まる場合は、
      /// それに対応する「わたしのレシピ」を取得する
      if (currentRecipe.documentId.startsWith('public_')) {
        doc = await FirebaseFirestore.instance
            .collection('users/${currentRecipe.userId}/recipes')
            .doc(currentRecipe.documentId.replaceFirst('public_', ''))
            .get();
      } else {
        doc = await FirebaseFirestore.instance
            .collection('users/${currentRecipe.userId}/recipes')
            .doc(this.currentRecipe.documentId)
            .get();
      }
    } else {
      this.isMyRecipe = false;
      doc = await FirebaseFirestore.instance
          .collection('public_recipes')
          .doc(currentRecipe.documentId)
          .get();
    }

    currentRecipe = Recipe(doc);
    currentRecipe.isMyRecipe = this.isMyRecipe;
    editRecipe = Recipe(doc);
    editRecipe.isMyRecipe = this.isMyRecipe;
    documentId = currentRecipe.documentId;

    endLoading();
    notifyListeners();
  }

  Future fetchRecipeEdit(context) async {
    final docs = await FirebaseFirestore.instance.collection('recipes').get();
    final recipes = docs.docs.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;
    notifyListeners();
  }

  extractIngredients() {
    final exp = RegExp(r'(?<=【)[^【】]+(?=】)');
    this.editRecipe.ingredients = exp
        .allMatches(this.editRecipe.content)
        .map((match) => match.group(0))
        .toList();
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

    isEdit = true;
    notifyListeners();
  }

  callNotifyListeners() {
    notifyListeners();
  }

  // 修正ボタン押下時
  editButtonTapped() async {
    startLoading();
    if (editRecipe.name.isEmpty) {
      throw ('レシピ名を入力してください');
    }
    if (editRecipe.content.isEmpty) {
      throw ('作り方・材料を入力してください');
    }

    /// レシピ名とレシピの全文を検索対象にする場合
    List _preTokenizedList = [];
    _preTokenizedList.add(editRecipe.name);
    _preTokenizedList.add(editRecipe.content);

    List _tokenizeList = tokenize(_preTokenizedList);
    editRecipe.tokenMap =
        Map.fromIterable(_tokenizeList, key: (e) => e, value: (_) => true);
    print(editRecipe.tokenMap);

    // 画像が変更されている場合のみ実行する
    if (this.imageFile != null) {
      if (currentRecipe.imageURL.isNotEmpty) {
        await _deleteImage();
      }

      await _uploadImage();
      await _uploadThumbnail();
    }

    recipeUpdate = {
      'name': editRecipe.name,
      'imageURL': editRecipe.imageURL,
      'thumbnailURL': editRecipe.thumbnailURL,
      'imageName': editRecipe.imageName,
      'thumbnailName': editRecipe.thumbnailName,
      'content': editRecipe.content,
      'reference': editRecipe.reference,
      'updateAt': FieldValue.serverTimestamp(),
      'ingredients': editRecipe.ingredients,
      'tokenMap': editRecipe.tokenMap,
      'isPublic': editRecipe.isPublic,
      'isAccept': editRecipe.isAccept,
    };

    recipeAdd = recipeUpdate;
    recipeAdd.addAll({
      'documentId': 'public_$documentId',
      'userId': _auth.currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();

    var userRecipeGroup = firestore
        .collection('users/${_auth.currentUser.uid}/recipes')
        .doc(currentRecipe.documentId);

    var publicRecipeGroup =
        firestore.collection('public_recipes').doc('public_$documentId');

    // 公開範囲が私のレシピ & その他
    batch.update(userRecipeGroup, recipeUpdate);

    // 公開範囲がみんなのレシピのまま
    if (this.editRecipe.isPublic == true &&
        this.currentRecipe.isPublic == true) {
      batch.update(publicRecipeGroup, recipeUpdate);
    }

    // 公開範囲をみんなのレシピに変更
    if (this.editRecipe.isPublic == true &&
        this.currentRecipe.isPublic == false) {
      batch.set(publicRecipeGroup, recipeAdd);
    }

    // 公開範囲を私のレシピに変更
    if (this.editRecipe.isPublic == false &&
        this.currentRecipe.isPublic == true) {
      batch.delete(publicRecipeGroup);
    }

    batch.commit();
//    .then((doc) {
//      // 成功したときの処理を書きたいとき
//    });
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
    editRecipe.imageURL = await _snapshot.ref.getDownloadURL();
    editRecipe.imageName = _fileName;
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
    editRecipe.thumbnailURL = await _snapshot.ref.getDownloadURL();
    editRecipe.thumbnailName = _fileName;
  }

  // FirebaseStorageから画像を削除する
  Future _deleteImage() async {
    final image = currentRecipe.imageName;
    final storage = FirebaseStorage.instance;
    var desertRef = storage.ref().child('images/$image');
    desertRef.delete();
  }

  changeRecipeName(text) {
    this.editRecipe.name = text;
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
    this.editRecipe.content = text;
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
    this.editRecipe.reference = text;
    if (text.length > 1000) {
      this.isReferenceValid = false;
      this.errorReference = '1000文字以内で入力して下さい。';
    } else {
      this.isReferenceValid = true;
      this.errorReference = '';
    }
    notifyListeners();
  }

  void clickCheckBox(val) {
    this.editRecipe.isAccept = val;
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
