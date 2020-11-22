import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/search/search_page.dart';
import 'package:recipe/presentation/top/top_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズを取得
    final Size _size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<TopModel>(
      create: (_) => TopModel()..checkAppVersion(),
      child: Consumer<TopModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: Stack(
              children: [
                SearchPage(),
                model.isNewest
                    ? SizedBox()
                    : Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: _size.width - 32.0,
                            height: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '最新バージョンのお知らせ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Text(
                                    '「シンプルなレシピ」の最新版 (ver. ${model.newestVersion}) がリリースされました！'
                                    '下記のリンクより最新版をインストールしてご利用下さい。'),
                                SizedBox(
                                  height: 16.0,
                                ),
                                InkWell(
                                  child: RaisedButton(
                                    color: Color(0xFFF39800),
                                    textColor: Colors.white,
                                    child: Text('App Store で確認する'),
                                    onPressed: () async {
                                      if (await canLaunch(
                                          'https://apps.apple.com/jp/app/kboy%E3%81%AEflutter%E5%A4%A7%E5%AD%A6/id1532391360?l=en')) {
                                        await launch(
                                            'https://apps.apple.com/jp/app/kboy%E3%81%AEflutter%E5%A4%A7%E5%AD%A6/id1532391360?l=en');
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
