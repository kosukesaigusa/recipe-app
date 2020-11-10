import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  Recipe(DocumentSnapshot doc) {
    documentId = doc.id;
    userId = doc.data()['userId'];
    createdAt = doc.data()['createdAt'];
    updatedAt = doc.data()['updatedAt'];
    name = doc.data()['name'];
    thumbnailURL = doc.data()['thumbnailURL'];
    thumbnailName = doc.data()['thumbnailName'];
    imageURL = doc.data()['imageURL'];
    imageName = doc.data()['imageName'];
    content = doc.data()['content'];
    ingredients = doc.data()['ingredients'];
    reference = doc.data()['reference'];
    tokenMap = doc.data()['tokenMap'];
    isPublic = doc.data()['isPublic'];
    isMyRecipe = false;
  }

  String documentId;
  String userId;
  Timestamp createdAt;
  Timestamp updatedAt;
  String name;
  String thumbnailURL;
  String thumbnailName;
  String imageURL;
  String imageName;
  String content;
  List ingredients;
  String reference;
  Map tokenMap;
  bool isPublic;
  bool isMyRecipe;
}
