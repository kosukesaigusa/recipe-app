import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_model.dart';
import 'package:recipe/presentation/top/top_page.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/common/text_dialog.dart';

class RecipeEditPage extends StatelessWidget {
  RecipeEditPage(this.recipe);
  final nameController = TextEditingController();
  final contentController = TextEditingController();
  final referenceURLController = TextEditingController();
  Recipe recipe;

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
            //button 1
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text = contentController.text,
                  contentController.text = contentController.text + '【',
                  contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: contentController.text.length)),
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
            //button 2
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text = contentController.text,
                  contentController.text += '】',
                  contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: contentController.text.length)),
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
    return ChangeNotifierProvider<RecipeEditModel>(
        create: (_) =>  RecipeEditModel(this.recipe),
        builder: (context, snapshot) {
          return KeyboardActions(
            config: _buildConfig(context),
            child: Consumer<RecipeEditModel>(builder: (context, model, child) {
              nameController.text = model.editRecipe.name;
              contentController.text = model.editRecipe.content;
              referenceURLController.text = model.editRecipe.reference;
              final Size _size = MediaQuery.of(context).size;
              return Stack(
              children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            height: 20,
                            child: FlatButton(
                              visualDensity: VisualDensity(horizontal: -4.0, vertical: 0.0),
                              padding: EdgeInsets.zero,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.clear,
                                color: Colors.blue,
                              ),
                              height: 20,
                            ),
                          ),
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
                            initialValue: model.editRecipe.name,
                            textInputAction: TextInputAction.done,
                            onChanged: (text) {
                              model.changeRecipeName(text);
                              model.isEdit = true;
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: 'レシピ名',
                              border: OutlineInputBorder(),
                              errorText:
                              model.errorName == '' ? null : model.errorName,
                            ),
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.0,
                            ),
                          ),
                          _bigMargin(),
                          Text(
                            '2.写真',
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
                              child: model?.imageFile == null
                                  ? model.currentRecipe.imageURL == null || model.currentRecipe.imageURL.isEmpty
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
                                    : Image.network(
                                      model.currentRecipe.imageURL
                                      )
                                  : Image.file(
                                    model?.imageFile,
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          model.editRecipe.ingredients == null
                              ? Container()
                              : Text(model.editRecipe.ingredients.join('・')),
                          _smallMargin(),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            controller: contentController,
                            focusNode: _nodeText,
                            onChanged: (text) {
                              model.changeRecipeContent(text);
                              model.extractIngredients();
                              model.isEdit = true;
                            },
                            minLines: 12,
                            maxLines: 20,
                            decoration: InputDecoration(
                              labelText: 'レシピの内容（作り方・材料）',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              errorText: model.errorContent == ''
                                  ? null
                                  : model.errorContent,
                            ),
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.4,
                            ),
                          ),
                          _bigMargin(),
                          Text(
                            '4.参考にしたレシピ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _smallMargin(),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            controller: referenceURLController,
                            onChanged: (text) {
                              model.isEdit = true;
                              model.changeRecipeReference(text);
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: '参考にしたレシピのURLや書籍名を記入',
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.0,
                            ),
                          ),
                          _bigMargin(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '5.公開',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    activeColor: Colors.red,
                                    checkColor: Colors.white,
                                    onChanged: (bool val) {
                                      model.clickCheckBox(val);
                                    },
                                    value: model.editRecipe.isAccept
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: RaisedButton(
                                      child: Text(
                                        model.editRecipe.isPublic
                                            ? "公開を取り下げる" : "変更する",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      onPressed: model.isEdit || model.editRecipe.isPublic
                                          ? () async {
                                        model.editRecipe.isAccept = false;
                                        model.editRecipe.isPublic = false;
                                        await editButtonTapped(model, context);
                                      }
                                      : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: RaisedButton(
                                      child: Text(
                                        model.editRecipe.isPublic
                                        ? "変更する" : "みんなのレシピに公開",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      onPressed: model.editRecipe.isAccept
                                                  && model.currentRecipe.isPublic == false
                                                  && model.isNameValid
                                                  && model.isContentValid
                                                  && model.isReferenceValid
                                                  || model.editRecipe.isAccept
                                                  && model.isEdit
                                                  && model.isNameValid
                                                  && model.isContentValid
                                                  && model.isReferenceValid
                                          ? () async {
                                              model.editRecipe.isPublic = true;
                                              await editButtonTapped(model, context);
                                            }
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                  ),
                  model.isUploading
                    ? Container(
                      height: _size.height,
                      width: _size.width,
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
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
            }),
          );
        }
        );
  }
}

Future editButtonTapped(RecipeEditModel model, BuildContext context) async {
  try {
    await model.editButtonTapped();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('レシピを変更しました。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new TopPage()),
                        (_) => false);
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  } catch (e) {
    showTextDialog(context, e.toString());
  }
}
