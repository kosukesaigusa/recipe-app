import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class RecipeAddPage extends StatelessWidget {
  final nameController = TextEditingController();
  final contentController = TextEditingController();
  final referenceURLController = TextEditingController();

  Widget _h8sizedBox() {
    return SizedBox(
      height: 8,
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
    return ChangeNotifierProvider<RecipeAddModel>(
        create: (_) => RecipeAddModel(),
        builder: (context, snapshot) {
          return KeyboardActions(
            config: _buildConfig(context),
            child: Consumer<RecipeAddModel>(builder: (context, model, child) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.レシピ名',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _h8sizedBox(),
                        Container(
                          height: 30,
                          child: TextField(
                            controller: nameController,
                            onChanged: (text) {
                              model.recipeAdd.name = text;
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: 'レシピ名',
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.0,
                            ),
                          ),
                        ),
                        _h8sizedBox(),
                        Text(
                          '2.写真',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 150,
                          child: InkWell(
                            onTap: () {
                              model.showImagePicker();
                            },
                            child: model?.imageFile == null
                                ? Image.network(
                                    'https://d3a3a5e2ntl4bk.cloudfront.net/uploads/2020/02/Apple-SteveJobs.jpg')
                                : Image.file(
                                    model?.imageFile,
                                  ),
                          ),
                        ),
                        _h8sizedBox(),
                        Text(
                          '3.作り方・材料',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _h8sizedBox(),
                        model.recipeAdd.ingredients == null
                            ? Container()
                            : Text(model.recipeAdd.ingredients.join('・')),
                        _h8sizedBox(),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: contentController,
                          focusNode: _nodeText,
                          onChanged: (text) {
                            model.recipeAdd.content = text;
                            model.extractIngredients();
                          },
                          minLines: 8,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: 'レシピをここに記入します',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        _h8sizedBox(),
                        Text(
                          '4.参考にしたレシピ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _h8sizedBox(),
                        Container(
                          height: 30,
                          child: TextField(
                            controller: referenceURLController,
                            onChanged: (text) {
                              model.recipeAdd.reference = text;
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: '参考にしたレシピのURLや書籍名を記入',
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              fontSize: 15.0,
                              height: 1.0,
                            ),
                          ),
                        ),
                        _h8sizedBox(),
                        Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '5.公開',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      activeColor: Colors.red,
                                      checkColor: Colors.white,
                                      onChanged: (bool val) {
                                        model.recipeAdd.isAccept = val;
                                        model.clickCheckBox();
                                      },
                                      value: model.recipeAdd.isAccept == null
                                          ? false
                                          : model.recipeAdd.isAccept,
                                    ),
                                    Text(
                                      '公開するレシピのガイドラインを読んで同意しました',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      onPressed: () async {
                                        await addRecipe(model, context);
                                      },
                                    ),
                                    SizedBox(
                                      width: 20,
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
                                      onPressed: model.recipeAdd.isAccept
                                          ? () async {
                                              model.recipeAdd.isPublic = true;
                                              await addRecipe(model, context);
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            model.isUploading
                                ? Container(
                                    height: 160,
                                    color: Colors.grey.withOpacity(0.7),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }
}

Future addRecipe(RecipeAddModel model, BuildContext context) async {
  try {
    await model.addRecipeToFirebase();
    await showDialog(
      context: context,
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
    showDialog(
      context: context,
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
