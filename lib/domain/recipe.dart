import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  Recipe(DocumentSnapshot doc) {
    documentId = doc.id;
    userId = doc.data()['userId'];
    createdAt = doc.data()['createdAt'];
    updatedAt = doc.data()['updatedAt'];
    name = doc.data()['name'];
    thumbnailURL = doc.data()['thumbnailURL'];
    imageURL = doc.data()['imageURL'];
    content = doc.data()['content'];
    ingredients = doc.data()['ingredients'];
    reference = doc.data()['reference'];
    tokenMap = doc.data()['tokenMap'];
    isPublic = doc.data()['isPublic'];
    isAccept = doc.data()['isAccept'];
  }

  String documentId;
  String userId;
  Timestamp createdAt;
  Timestamp updatedAt;
  String name;
  String thumbnailURL;
  String imageURL;
  String content;
  List ingredients;
  String reference;
  Map tokenMap;
  bool isPublic;
  bool isAccept;
}
