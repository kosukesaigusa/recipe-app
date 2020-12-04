import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/convert_weekday_name.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/contact/contact_page.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_page.dart';

class RecipePage extends StatelessWidget {
  RecipePage(this.recipe);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel(this.recipe),
      child: Consumer<RecipeModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(36.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                centerTitle: true,
                title: model.isLoading
                    ? SizedBox()
                    : Text(
                        '${model.recipe.name}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                actions: <Widget>[
                  model.isLoading
                      ? SizedBox()
                      : IconButton(
                          icon: Icon(
                            Icons.loupe,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailPage(model.recipe),
                              ),
                            );
                          },
                        ),
                  model.isLoading
                      ? SizedBox()
                      : model.recipe.isMyRecipe
                          ? IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeEditPage(model.recipe),
                                  ),
                                );
                              },
                            )
                          : model.showReportIcon
                              ? IconButton(
                                  icon: Icon(
                                    Icons.report,
                                    size: 20.0,
                                  ),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text('不適切な内容や画像として報告しますか？'),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('キャンセル'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('報告する'),
                                              onPressed: () async {
                                                await Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ContactPage(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : SizedBox(),
                ],
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      // 右スワイプ
                      if (details.delta.dx > 20) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        right: 16.0,
                        bottom: 48.0,
                        left: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          model.isLoading
                              ? SizedBox()
                              : Container(
                                  // color: Colors.grey,
                                  height: 28,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      model.recipe.isMyRecipe
                                          ? Container(
                                              height: 28,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              color: Color(0xFFF39800),
                                              child: Text(
                                                'わたしのレシピ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 28,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              color: Colors.grey,
                                              child: Text(
                                                'みんなのレシピ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      model.recipe.isPublic
                                          ? Container(
                                              height: 28,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              color: Color(0xFFF39800),
                                              child: Text(
                                                '公開中',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 28,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              color: Colors.grey,
                                              child: Text(
                                                '非公開',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          model.pressedFavoriteButton();
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 28,
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                                right: 6.0,
                                                bottom: 4.0,
                                                left: 8.0,
                                              ),
                                              color: model.recipe.isFavorite
                                                  ? Color(0xFFF39800)
                                                  : Colors.grey,
                                              child: Text(
                                                'お気に入り',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 28,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: model.recipe.isFavorite
                                                      ? Color(0xFFF39800)
                                                      : Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              child: model.recipe.isFavorite
                                                  ? Icon(
                                                      Icons.favorite,
                                                      size: 20,
                                                      color: Color(0xFFF39800),
                                                    )
                                                  : Icon(
                                                      Icons.favorite_border,
                                                      size: 20,
                                                      color: Colors.grey,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 8,
                          ),
                          model.isLoading
                              ? SizedBox()
                              : Container(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl: '${model.authorIconURL}',
                                            placeholder: (context, url) =>
                                                Container(
                                              child: Icon(
                                                Icons.person,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.person,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      model.authorDisplayName == null
                                          ? SizedBox()
                                          : Text(
                                              '${model.authorDisplayName}',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      model.isLoading
                                          ? SizedBox()
                                          : Text(
                                              '${'${model.recipe.updatedAt.toDate()}'.substring(0, 10)} '
                                              '${convertWeekdayName(model.recipe.updatedAt.toDate().weekday)}'
                                              ' ${'${model.recipe.updatedAt.toDate()}'.substring(11, 16)} 更新',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'レシピ名',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SelectableText('${model.recipe.name}'),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: model.isLoading
                                  ? Container(
                                      color: Color(0xFFDADADA),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Loading...',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : '${model.recipe.imageURL}' == ''
                                      ? Container(
                                          color: Color(0xFFDADADA),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No photo',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: '${model.recipe.imageURL}',
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Color(0xFFDADADA),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Loading...',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              //Icon(Icons.error),
                                              Container(
                                            color: Color(0xFFDADADA),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    Icon(Icons.error_outline),
                                              ),
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '作り方・材料',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SelectableText('${model.recipe.content}'),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          model.recipe.reference == ''
                              ? SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '参考にしたレシピ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SelectableText('${model.recipe.reference}'),
                                  ],
                                ),
                        ],
                      ),
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
                    : SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }
}
