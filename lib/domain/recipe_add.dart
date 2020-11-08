import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeAdd {
  RecipeAdd({
    this.userId = '',
    this.createdAt,
    this.updatedAt,
    this.name = '',
    this.thumbnailURL = '',
    this.imageURL = '',
    this.content = '',
    this.ingredients,
    this.reference = '',
    this.tokenMap,
    this.isPublic = false,
    this.isAccept = false,
  });

  String userId = '';
  Timestamp createdAt;
  Timestamp updatedAt;
  String name = '';
  String thumbnailURL = '';
  String imageURL = '';
  String thumbnailName = '';
  String imageName = '';
  String content = '';
  List<String> ingredients;
  String reference = '';
  Map<String, bool> tokenMap;
  bool isPublic = false;
  bool isAccept = false;
}
