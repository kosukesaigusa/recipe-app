import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class RecipeAddPage extends StatelessWidget {
  final nameController = TextEditingController();
  final contentController = TextEditingController();
  final referenceController = TextEditingController();

  Widget _smallMargin() {
    return SizedBox(
      height: 8,
    );
  }

  Widget _bigMargin() {
    return SizedBox(
      height: 16,
    );
  }

  final FocusNode _nodeText = FocusNode();

  // カスタムキーボドードのコンフィグ
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText,
          toolbarButtons: [
            // button 1
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text = contentController.text,
                  contentController.text = contentController.text + '【',
                  contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: contentController.text.length),
                  ),
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "【",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
            // button 2
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text = contentController.text,
                  contentController.text += '】',
                  contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: contentController.text.length),
                  ),
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "】",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeAddModel>(
      create: (_) => RecipeAddModel(),
      child: Consumer<RecipeAddModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              Scaffold(
                body: KeyboardActions(
                  config: _buildConfig(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(text: '1. レシピ名'),
                              TextSpan(
                                text: '（必須）',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _smallMargin(),
                        TextFormField(
                          // controller: nameController,
                          initialValue: model.recipeAdd.name,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            model.changeRecipeName(text);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'レシピ名',
                            border: OutlineInputBorder(),
                            errorText:
                                model.errorName == '' ? null : model.errorName,
                          ),
                          style: TextStyle(
                            fontSize: 10.0,
                            height: 1.0,
                          ),
                        ),
                        _bigMargin(),
                        Text(
                          '2. 写真',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _smallMargin(),
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
                                                  fontSize: 10,
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
                        _bigMargin(),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(text: '3. 作り方・材料'),
                              TextSpan(
                                text: '（必須）',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        model.recipeAdd.ingredients == null
                            ? Container()
                            : Text(
                                model.recipeAdd.ingredients.join('・'),
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                        _smallMargin(),
                        TextFormField(
                          // controller: contentController,
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.content,
                          focusNode: _nodeText,
                          onChanged: (text) {
                            model.changeRecipeContent(text);
                            model.extractIngredients();
                          },
                          minLines: 12,
                          maxLines: 12,
                          decoration: InputDecoration(
                            labelText: 'レシピの内容（作り方・材料）',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            errorText: model.errorContent == ''
                                ? null
                                : model.errorContent,
                          ),
                          style: TextStyle(
                            fontSize: 10.0,
                            height: 1.4,
                          ),
                        ),
                        _bigMargin(),
                        Text(
                          '4. 参考にしたレシピ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _smallMargin(),
                        TextFormField(
                          // controller: referenceController,
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.reference,
                          onChanged: (text) {
                            model.changeRecipeReference(text);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: '参考にしたレシピのURLや書籍名を記入',
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            fontSize: 10.0,
                            height: 1.0,
                          ),
                        ),
                        _bigMargin(),
                        Text(
                          '5. 投稿',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              activeColor: Colors.red,
                              checkColor: Colors.white,
                              onChanged: (val) {
                                model.clickCheckBox(val);
                              },
                              value: model.recipeAdd.isAccept,
                            ),
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(text: '公開するレシピの'),
                                    TextSpan(
                                      text: 'ガイドライン',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: 'を読んで同意しました。'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton(
                              child: Text(
                                "わたしのレシピに追加",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: model.isNameValid &&
                                      model.isContentValid &&
                                      model.isReferenceValid
                                  ? () async {
                                      model.startLoading();
                                      await addRecipe(model, context);
                                      model.endLoading();
                                    }
                                  : null,
                            ),
                            RaisedButton(
                              child: Text(
                                "みんなのレシピに公開",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: model.isNameValid &&
                                      model.isContentValid &&
                                      model.isReferenceValid
                                  ? model.recipeAdd.isAccept
                                      ? () async {
                                          model.startLoading();
                                          model.recipeAdd.isPublic = true;
                                          await addRecipe(model, context);
                                          model.endLoading();
                                        }
                                      : null
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              model.isUploading
                  ? Container(
                      color: Colors.grey.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 16,
                            ),
                            Text('レシピを保存しています...'),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

Future addRecipe(RecipeAddModel model, BuildContext context) async {
  try {
    await model.addRecipeToFirebase();
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
                // Navigator.of(context).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopPage(),
                    fullscreenDialog: true,
                  ),
                );
                model.fetchRecipeAdd(context);
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
          title: Text(e.toString()),
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
