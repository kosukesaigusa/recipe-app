import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/domain/recipe_add.dart';

class RecipeAddModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  RecipeAdd recipeAdd = RecipeAdd(isPublic: false);
  List<Recipe> recipes = [];
  File imageFile;
  bool isUploading = false;
  String tmp;

  Future fetchRecipeAdd(context) async {
    final docs = await FirebaseFirestore.instance.collection('recipes').get();
    final recipes = docs.docs.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;
    notifyListeners();
  }

  extractIngredients() {
    final exp = RegExp(r'(?<=【)[^【】]+(?=】)');
    this.recipeAdd.ingredients = exp
        .allMatches(this.recipeAdd.content)
        .map((match) => match.group(0))
        .toList();
    notifyListeners();
  }

  Future showImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedImage = File(pickedFile.path);

    // 画像をアス比1:1で切り抜く
    if (pickedImage != null) {
      this.imageFile = await ImageCropper.cropImage(
        sourcePath: pickedImage.path,
        maxHeight: 150,
        aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
        compressFormat: ImageCompressFormat.png,
        compressQuality: 10,
        iosUiSettings: IOSUiSettings(
          title: '編集',
        ),
      );
    }
    notifyListeners();
  }

  clickCheckBox() {
    notifyListeners();
  }

  Future addRecipeToFirebase() async {
    if (recipeAdd.name.isEmpty) {
      throw ('レシピ名を入力してください');
    }
    if (recipeAdd.content.isEmpty) {
      throw ('作り方・材料を入力してください');
    }

    this.isUploading = true;
    notifyListeners();

    // 画像が変更されている場合のみ実行する
    if (this.imageFile != null) {
      recipeAdd.imageURL = await _upLoadImage();
      // todo: サムネイル用画像のリサイズ
      recipeAdd.thumbnailURL = recipeAdd.imageURL;
    }

    // ディープコピーしています もっとスマートなやり方がありそう
    List _preTokenizeList = [...recipeAdd.ingredients];
    _preTokenizeList.add(recipeAdd.name);

    List _tokenizeList = tokenize(_preTokenizeList);
    recipeAdd.tokenMap =
        Map.fromIterable(_tokenizeList, key: (e) => e, value: (_) => true);
    print(recipeAdd.tokenMap);

    String generatedId;

    await FirebaseFirestore.instance
        .collection('users/${_auth.currentUser.uid}/recipes')
        .add(
          {
            'userId': _auth.currentUser.uid,
            'name': recipeAdd.name,
            'imageURL': recipeAdd.imageURL,
            'thumbnailURL': recipeAdd.thumbnailURL,
            'content': recipeAdd.content,
            'reference': recipeAdd.reference,
            'createdAt': FieldValue.serverTimestamp(),
            'updateAt': FieldValue.serverTimestamp(),
            'ingredients': recipeAdd.ingredients,
            'tokenMap': recipeAdd.tokenMap,
            'isPublic': recipeAdd.isPublic,
            'isAccept': recipeAdd.isAccept,
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
          'name': recipeAdd.name,
          'imageURL': recipeAdd.imageURL,
          'thumbnailURL': recipeAdd.thumbnailURL,
          'content': recipeAdd.content,
          'reference': recipeAdd.reference,
          'createdAt': FieldValue.serverTimestamp(),
          'updateAt': FieldValue.serverTimestamp(),
          'ingredients': recipeAdd.ingredients,
          'tokenMap': recipeAdd.tokenMap,
          'isPublic': recipeAdd.isPublic,
          'isAccept': recipeAdd.isAccept,
        },
      );
    }

    this.isUploading = false;
    notifyListeners();
  }

  // Firestoreにアップロードする
  Future<String> _upLoadImage() async {
    String _fileName = FieldValue.serverTimestamp().toString() +
        _auth.currentUser.uid +
        '.png';
    final storage = FirebaseStorage.instance;
    StorageTaskSnapshot snapshot =
        await storage.ref().child(_fileName).putFile(this.imageFile).onComplete;
    final String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  // 【】に囲まれた文字列を抽出する
  List<String> _splitMoves(String content) {
    final exp = RegExp(r'(?<=【)[^【】]+(?=】)');
    return exp.allMatches(content).map((match) => match.group(0)).toList();
  }
}
