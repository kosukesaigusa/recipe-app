import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/convert_weekday_name.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';
import 'package:recipe/presentation/recipe_detail/recipe_detail_page.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_page.dart';

class RecipePage extends StatelessWidget {
  RecipePage(this.recipeDocumentId, this.recipeOwnerId);

  final String recipeDocumentId;
  final String recipeOwnerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) =>
          RecipeModel()..fetchRecipe(recipeDocumentId, recipeOwnerId),
      child: Consumer<RecipeModel>(builder: (context, model, child) {
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
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return RecipeDetailPage(model.recipe);
                              },
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
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return RecipeEditPage(model.recipe);
                                  },
                                  fullscreenDialog: true,
                                ),
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
                            : model.isMyRecipe
                                ? model.isPublic
                                    ? Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
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
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Container(
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
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
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
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Container(
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
                                          ],
                                        ),
                                      )
                                : Container(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      color: Colors.grey,
                                      child: Text(
                                        'みんなのレシピ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                        SizedBox(
                          height: 8,
                        ),
                        model.isLoading
                            ? SizedBox()
                            : Text(
                                '更新：'
                                '${'${model.recipe.updatedAt.toDate()}'.substring(0, 10)} '
                                '${convertWeekdayName(model.recipe.updatedAt.toDate().weekday)}'
                                ' ${'${model.recipe.updatedAt.toDate()}'.substring(11, 16)} ',
                              ),
                        SizedBox(
                          height: 8,
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
                            Text('${model.name}'),
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
                                : '${model.imageURL}' == ''
                                    ? Container(
                                        color: Color(0xFFDADADA),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                        imageUrl: '${model.imageURL}',
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
                                              child: Icon(Icons.error_outline),
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
                            Text('${model.content}'),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        model.reference == ''
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
                                  Text('${model.reference}'),
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
      }),
    );
  }
}
