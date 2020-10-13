import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/menu/menu_page.dart';
import 'package:recipe/presentation/recipe_add/recipe_add_page.dart';
import 'package:recipe/presentation/search/search_page.dart';
import 'package:recipe/presentation/top/top_model.dart';

class TopPage extends StatelessWidget {
  final List<String> _tabNames = [
    "記録する",
    "探す",
    "メニュー",
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopModel>(
      create: (_) => TopModel()..init(),
      child: Consumer<TopModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(_tabNames[model.currentIndex]),
            leading: SizedBox(),
            backgroundColor: Colors.blue,
          ),
          body: _topPageBody(context),
          bottomNavigationBar: BottomNavigationBar(
            onTap: model.onTabTapped,
            currentIndex: model.currentIndex,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                title: Text(_tabNames[0]),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: Text(_tabNames[1]),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                title: Text(_tabNames[2]),
              ),
            ],
          ),
        );
        //return _topPageBody(context);
      }),
    );
  }

  Widget _topPageBody(BuildContext context) {
    final model = Provider.of<TopModel>(context);
    final currentIndex = model.currentIndex;
    return Stack(
      children: <Widget>[
        _tabPage(currentIndex, 0, RecipeAddPage()),
        _tabPage(currentIndex, 1, SearchPage()),
        _tabPage(currentIndex, 2, MenuPage()),
      ],
    );
  }

  Widget _tabPage(int currentIndex, int tabIndex, StatelessWidget page) {
    return Visibility(
      visible: currentIndex == tabIndex,
      maintainState: true,
      child: page,
    );
  }
}
