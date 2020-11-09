import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class RecipeEditPage extends StatelessWidget {
  RecipeEditPage(this.recipe);
  final Recipe recipe;

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeEditModel>(
      create: (_) => RecipeEditModel(this.recipe),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('レシピの編集'),
        ),
        body: Consumer<RecipeEditModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        model.currentRecipe.isPublic
                            ? Container(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  color: Color(0xFFFFCC00),
                                  child: Text(
                                    '公開中',
                                    style: TextStyle(
                                      color: Color(0xFF0033FF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(4.0),
                                color: Colors.grey,
                                child: Text(
                                  '非公開',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                          initialValue: model.editRecipe.name,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            model.changeRecipeName(text);
                            model.isEdited = true;
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
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: model.isLoading
                                  ? Container(
                                      color: Color(0xFFDADADA),
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Loading...',
                                            style: TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : model?.imageFile == null
                                      ? model.currentRecipe.imageURL == null ||
                                              model.currentRecipe.imageURL
                                                  .isEmpty
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
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_photo_alternate,
                                                        ),
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
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  '${model.currentRecipe.imageURL}',
                                              errorWidget:
                                                  (context, url, error) =>
                                                      //Icon(Icons.error),
                                                      Container(
                                                color: Color(0xFFDADADA),
                                                width: 100,
                                                height: 100,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.error_outline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                      : Image.file(
                                          model?.imageFile,
                                        ),
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
                        _smallMargin(),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.editRecipe.content,
                          onChanged: (text) {
                            model.changeRecipeContent(text);
                            model.isEdited = true;
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
                          initialValue: model.editRecipe.reference,
                          onChanged: (text) {
                            model.isEdited = true;
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
                        model.editRecipe.isPublic
                            ? SizedBox()
                            : Column(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        activeColor: Colors.red,
                                        checkColor: Colors.white,
                                        onChanged: (val) {
                                          model.tapPublishCheckbox(val);
                                        },
                                        value: model.willPublish,
                                      ),
                                      Flexible(
                                        child: Text(
                                          'みんなのレシピにも公開',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  model.willPublish
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Checkbox(
                                              activeColor: Colors.red,
                                              checkColor: Colors.white,
                                              onChanged: (val) {
                                                model.tapAgreeCheckBox(val);
                                              },
                                              value: model.agreed,
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
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                        text: 'を読んで同意しました。'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton(
                              child: Text(
                                model.editRecipe.isPublic
                                    ? '公開を取り下げる'
                                    : 'レシピを更新する',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: model.isEdited ||
                                      model.editRecipe.isPublic
                                  ? () async {
                                      model.editRecipe.isPublic = false;
                                      await editButtonTapped(model, context);
                                    }
                                  : null,
                            ),
                            RaisedButton(
                              child: Text(
                                model.editRecipe.isPublic
                                    ? 'レシピを更新する'
                                    : 'みんなのレシピに公開する',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: model.agreed &&
                                          model.currentRecipe.isPublic ==
                                              false &&
                                          model.isNameValid &&
                                          model.isContentValid &&
                                          model.isReferenceValid ||
                                      model.agreed &&
                                          model.isEdited &&
                                          model.isNameValid &&
                                          model.isContentValid &&
                                          model.isReferenceValid
                                  ? () async {
                                      model.editRecipe.isPublic = true;
                                      await editButtonTapped(model, context);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox()
              ],
            );
          },
        ),
      ),
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
                      builder: (context) => new TopPage(),
                    ),
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
