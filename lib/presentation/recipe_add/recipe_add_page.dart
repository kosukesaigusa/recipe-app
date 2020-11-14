import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class RecipeAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeAddModel>(
      create: (_) => RecipeAddModel(),
      child: Consumer<RecipeAddModel>(
        builder: (context, model, child) {
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
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, right: 16.0, bottom: 48.0, left: 16.0),
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
                            fontSize: 14.0,
                            height: 1.0,
                          ),
                        ),
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.content,
                          onChanged: (text) {
                            model.changeRecipeContent(text);
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
                            fontSize: 14.0,
                            height: 1.4,
                          ),
                        ),
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
                          textInputAction: TextInputAction.done,
                          initialValue: model.recipeAdd.reference,
                          onChanged: (text) {
                            model.changeRecipeReference(text);
                          },
                          minLines: 3,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: '参考にしたレシピのURLや書籍名を記入',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
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
                              value: model.willPublish,
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
                        model.willPublish
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    activeColor: Color(0xFFF39800),
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
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(text: '公開するレシピの'),
                                          TextSpan(
                                            text: 'ガイドライン',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: 'を読んで同意しました。'),
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
                              onPressed: model.isNameValid &&
                                      model.isContentValid &&
                                      model.isReferenceValid
                                  ? model.willPublish
                                      ? model.agreed
                                          ? () async {
                                              model.recipeAdd.isPublic = true;
                                              await addRecipe(model, context);
                                            }
                                          : null
                                      : () async {
                                          model.recipeAdd.isPublic = false;
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
