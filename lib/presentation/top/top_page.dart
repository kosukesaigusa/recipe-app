import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/search/search_page.dart';
import 'package:recipe/presentation/top/top_model.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopModel>(
      create: (_) => TopModel()..init(),
      child: Consumer<TopModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: SearchPage(),
          );
        },
      ),
    );
  }
}
