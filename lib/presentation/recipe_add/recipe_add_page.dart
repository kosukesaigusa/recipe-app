import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/done_button.dart';
import 'package:recipe/presentation/guideline/guideline_page.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_model.dart';
import 'package:recipe/presentation/recipe_writing_hint/recipe_writing_hint.dart';
import 'package:recipe/presentation/top/top_page.dart';
import 'package:vibrate/vibrate.dart';

class RecipeAddPage extends StatelessWidget {
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeContent = FocusNode();
  final FocusNode _focusNodeReference = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        _keyboardActionItems(_focusNodeContent),
        _keyboardActionItems(_focusNodeReference),
      ],
    );
  }

  _keyboardActionItems(_focusNode) {
    return KeyboardActionsItem(
      focusNode: _focusNode,
      toolbarButtons: [
        /// 「完了」ボタン
        (node) {
          return customDoneButton(_focusNode);
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeAddModel>(
      create: (_) => RecipeAddModel(),
      child: Consumer<RecipeAddModel>(
        builder: (context, model, child) {
          // レシピ名, 作り方・材料, 参考にしたレシピの
          // 3 つのフィールドのフォーカス状況の管理
          this._focusNodeName.addListener(() {
            model.recipeAdd.isNameFocused = this._focusNodeName.hasFocus;
            model.focusRecipeName(this._focusNodeName.hasFocus);
          });
          this._focusNodeContent.addListener(() {
            model.recipeAdd.isContentFocused = this._focusNodeContent.hasFocus;
            model.focusRecipeContent(this._focusNodeContent.hasFocus);
          });
          this._focusNodeReference.addListener(() {
            model.recipeAdd.isReferenceFocused =
                this._focusNodeReference.hasFocus;
            model.focusRecipeReference(this._focusNodeReference.hasFocus);
          });
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(32.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                centerTitle: true,
                title: Text(
                  'レシピの追加',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.0,
                  ),
                  onPressed: () {
                    if (model.recipeAdd.name.isNotEmpty ||
                        model.imageFile != null ||
                        model.recipeAdd.content.isNotEmpty ||
                        model.recipeAdd.reference.isNotEmpty) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              '編集中の内容は失われますが、'
                              '作業を中止して前の画面に戻りますか？',
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('OK'),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
            body: Stack(
              children: [
                KeyboardActions(
                  config: _buildConfig(context),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        right: 16.0,
                        bottom: 48.0,
                        left: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '1. レシピ名',
                                ),
                                TextSpan(
                                  text: '（必須）',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            focusNode: this._focusNodeName,
                            initialValue: model.recipeAdd.name,
                            textInputAction: TextInputAction.done,
                            onChanged: (text) {
                              model.changeRecipeName(text);
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: 'レシピ名',
                              border: OutlineInputBorder(),
                              errorText: model.recipeAdd.errorName == ''
                                  ? null
                                  : model.recipeAdd.errorName,
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                              height: 1.0,
                            ),
                          ),
                          model.recipeAdd.isNameFocused &&
                                  model.recipeAdd.name.length >= 20 &&
                                  model.recipeAdd.name.length <= 30
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 12.0,
                                  ),
                                  child: Text(
                                    '残り ${30 - model.recipeAdd.name.length} 文字です。',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFF39800),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            '2. 写真',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 150,
                            child: InkWell(
                              onTap: () {
                                model.showImagePicker();
                              },
                              child: model.imageFile == null
                                  ? SizedBox(
                                      width: 200,
                                      height: 150,
                                      child: Stack(
                                        children: [
                                          Container(
                                            color: Color(0xFFDADADA),
                                          ),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_photo_alternate),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  'タップして画像を追加',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Image.file(
                                      model.imageFile,
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '3. 作り方・材料',
                                ),
                                TextSpan(
                                  text: '（必須）',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: '書き方のヒント',
                                  style: TextStyle(
                                    color: Color(0xFFF39800),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeWritingHintPage(),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            focusNode: this._focusNodeContent,
                            keyboardType: TextInputType.multiline,
                            initialValue: model.recipeAdd.content,
                            onChanged: (text) {
                              model.changeRecipeContent(text);
                            },
                            minLines: 12,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'レシピの内容（作り方・材料）',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              errorText: model.recipeAdd.errorContent == ''
                                  ? null
                                  : model.recipeAdd.errorContent,
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                              height: 1.4,
                            ),
                          ),
                          model.recipeAdd.isContentFocused &&
                                  model.recipeAdd.content.length >= 900 &&
                                  model.recipeAdd.content.length <= 1000
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 12.0,
                                  ),
                                  child: Text(
                                    '残り ${1000 - model.recipeAdd.content.length} 文字です。',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFF39800),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            '4. 参考にしたレシピ',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            focusNode: this._focusNodeReference,
                            keyboardType: TextInputType.multiline,
                            initialValue: model.recipeAdd.reference,
                            onChanged: (text) {
                              model.changeRecipeReference(text);
                            },
                            minLines: 1,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: '参考にしたレシピのURLや書籍名を記入',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              errorText: model.recipeAdd.errorReference == ''
                                  ? null
                                  : model.recipeAdd.errorReference,
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            '5. 投稿',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                activeColor: Color(0xFFF39800),
                                checkColor: Colors.white,
                                onChanged: (val) {
                                  model.tapPublishCheckbox(val);
                                },
                                value: model.recipeAdd.willPublish,
                              ),
                              Flexible(
                                child: Text(
                                  'みんなのレシピにも公開',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          model.recipeAdd.willPublish
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      activeColor: Color(0xFFF39800),
                                      checkColor: Colors.white,
                                      onChanged: (val) {
                                        model.tapAgreeCheckBox(val);
                                      },
                                      value: model.recipeAdd.agreeGuideline,
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(text: '公開するレシピの '),
                                            TextSpan(
                                              text: 'ガイドライン',
                                              style: TextStyle(
                                                color: Color(0xFFF39800),
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationThickness: 2.00,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GuidelinePage(),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );
                                                },
                                            ),
                                            TextSpan(text: ' を読んで同意しました。'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: RaisedButton(
                                child: Text(
                                  'レシピを保存する',
                                ),
                                color: Color(0xFFF39800),
                                textColor: Colors.white,
                                onPressed: model.recipeAdd.isNameValid &&
                                        model.recipeAdd.isContentValid &&
                                        model.recipeAdd.isReferenceValid
                                    ? model.recipeAdd.willPublish
                                        ? model.recipeAdd.agreeGuideline
                                            ? () async {
                                                model.recipeAdd.willPublish =
                                                    true;
                                                await addRecipe(model, context);
                                              }
                                            : null
                                        : () async {
                                            model.recipeAdd.willPublish = false;
                                            await addRecipe(model, context);
                                          }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                model.isUploading
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.withOpacity(0.7),
                        child: Center(
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      child: Text('レシピを保存しています...'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future addRecipe(RecipeAddModel model, BuildContext context) async {
  model.startLoading();
  try {
    await model.addRecipeToFirebase();
    model.endLoading();
    Vibrate.feedback(FeedbackType.medium);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('レシピを追加しました。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  } catch (e) {
    model.endLoading();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
