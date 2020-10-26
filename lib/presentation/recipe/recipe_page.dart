import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/recipe/recipe_model.dart';

class RecipePage extends StatelessWidget {
  final String userId;
  final String documentId;

  RecipePage(this.userId, this.documentId);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeModel>(
      create: (_) => RecipeModel(documentId, userId),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                // recipe deteil page
              },
              child: Text(
                "拡大する",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
              ),
            ),
          ],
            centerTitle: true,
            title: Icon(Icons.wb_sunny, color: Colors.white,),
        ),
        body: Consumer<RecipeModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(
                              color: Color(0xFFDADADA),
                              width: 1.0,
                              ),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                  child: Text(model.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                model.isMyRecipe ?
                                IconButton(
                                  onPressed: () {
                                    // edit page
                                  },
                                  icon: Icon(Icons.edit, color: Colors.blue,)
                                ) : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Image.network(
                        '${model.imageURL}',
                        ),
                        SizedBox(height: 16),
                        Text("作り方・材料",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                        ),
                        Text(model.content),
                        SizedBox(height: 16),
                        Text(
                          "参考にしたレシピ",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                        Text(model.content),
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
              : SizedBox(),
              ],
            );
          }
        ),
      ),
    );
  }
}

