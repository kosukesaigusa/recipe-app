import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeAdd {
  RecipeAdd() {
    this.userId = '';
    this.createdAt = null;
    this.updatedAt = null;
    this.name = '';
    this.thumbnailURL = '';
    this.imageURL = '';
    this.content = '';
    this.reference = '';
    this.tokenMap = {};
    this.willPublish = false;
    this.agreeGuideline = false;
    this.errorName = '';
    this.errorContent = '';
    this.errorReference = '';
    this.isNameValid = false;
    this.isContentValid = false;
    this.isReferenceValid = true;
  }

  String userId;
  Timestamp createdAt;
  Timestamp updatedAt;
  String name;
  String thumbnailURL;
  String imageURL;
  String thumbnailName;
  String imageName;
  String content;
  String reference;
  Map<String, bool> tokenMap;
  bool willPublish;
  bool agreeGuideline;
  String errorName;
  String errorContent;
  String errorReference;
  bool isNameValid;
  bool isContentValid;
  bool isReferenceValid;
}
