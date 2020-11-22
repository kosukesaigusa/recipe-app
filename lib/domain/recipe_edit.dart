import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeEdit {
  RecipeEdit() {
    this.updatedAt = null;
    this.name = '';
    this.thumbnailURL = '';
    this.thumbnailName = '';
    this.imageURL = '';
    this.imageName = '';
    this.content = '';
    this.reference = '';
    this.tokenMap = {};
    this.isEdited = false;
    this.willPublish = false;
    this.agreeGuideline = false;
    this.errorName = '';
    this.errorContent = '';
    this.errorReference = '';
    this.isNameFocused = false;
    this.isContentFocused = false;
    this.isReferenceFocused = false;
    this.isNameValid = true;
    this.isContentValid = true;
    this.isReferenceValid = true;
  }

  Timestamp updatedAt;
  String name;
  String thumbnailName;
  String thumbnailURL;
  String imageURL;
  String imageName;
  String content;
  String reference;
  Map<String, bool> tokenMap;
  bool isEdited;
  bool willPublish;
  bool agreeGuideline;
  String errorName;
  String errorContent;
  String errorReference;
  bool isNameFocused;
  bool isContentFocused;
  bool isReferenceFocused;
  bool isNameValid;
  bool isContentValid;
  bool isReferenceValid;
}
