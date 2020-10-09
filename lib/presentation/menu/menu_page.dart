import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_page.dart';
import 'package:recipe/presentation/menu/menu_model.dart';
import 'package:recipe/presentation/my_account/my_account_page.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuModel>(
      create: (_) => MenuModel()..fetchMenu(context),
      child: Consumer<MenuModel>(
        builder: (context, model, child) {
          return Container(
            width: double.infinity,
            child: ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(model.leadingLists[index]),
                  title: Text('${model.items[index]}'),
                  onTap: () {
                    switch (index) {
                      case 0:
                        return Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyAccountPage(),
                          ),
                        );
                      case 1:
                        return Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactPage(),
                            fullscreenDialog: true,
                          ),
                        );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
