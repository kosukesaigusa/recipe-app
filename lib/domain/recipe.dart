import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  Recipe(DocumentSnapshot doc) {
    this.documentId = doc.id;
    this.userId = doc.data()['userId'];
    this.createdAt = doc.data()['createdAt'];
    this.updatedAt = doc.data()['updatedAt'];
    this.likedAt = doc.data()['likedAt'];
    this.name = doc.data()['name'];
    this.thumbnailURL = doc.data()['thumbnailURL'];
    this.thumbnailName = doc.data()['thumbnailName'];
    this.imageURL = doc.data()['imageURL'];
    this.imageName = doc.data()['imageName'];
    this.content = doc.data()['content'];
    this.ingredients = doc.data()['ingredients'];
    this.reference = doc.data()['reference'];
    this.tokenMap = doc.data()['tokenMap'];
    this.isPublic = doc.data()['isPublic'];
    this.isMyRecipe = false;
    this.isFavorite = false;
  }

  String documentId;
  String userId;
  Timestamp createdAt;
  Timestamp updatedAt;
  Timestamp likedAt;
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
  bool isFavorite;

  // documentId リストを渡して自分の Id と合致しているか調べる
  void existFavorite(List<String> favoriteDocIdList) {
    this.isFavorite =
        favoriteDocIdList.contains(documentId.replaceFirst('public_', ''));
  }
}
