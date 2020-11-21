import 'package:flutter/material.dart';

class RecipeWritingHintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36.0),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
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
          title: Text(
            'レシピの書き方のヒント',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            right: 32.0,
            bottom: 48.0,
            left: 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '「シンプルなレシピ」は、調理中にレシピを閲覧する際に画面をスクロールする必要がないように、'
                'レシピの手順が材料とともに紹介される状況を想定しています。',
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('下記の良い例・そうでない例を参考にレシピをシンプルにまとめ、投稿しましょう！'),
              SizedBox(
                height: 16.0,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.check_circle,
                        size: 16.0,
                        color: Colors.green,
                      ),
                    ),
                    TextSpan(
                      text: '',
                    ),
                    TextSpan(
                      text: '：良い例（豚キムチの作り方）',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                color: Colors.green.withOpacity(0.3),
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'まず、豚こま肉を200g程度、塩こしょうと薄力粉でコーティングして下準備する。'
                  'ニンニクは2片ほどを荒みじん切り、玉ねぎ半分を薄めのスライスにしておく。\n'
                  '温めたフライパンにニンニクを入れて火を通し、柴犬色になったら肉をよく広げながら入れる。\n'
                  '全体に火が通ってきたら玉ねぎを入れて、透明になるまで炒める。そこにキムチ200gを投入して、'
                  '酒大さじ1、醤油小さじ1、砂糖小さじ1、めんつゆ少々を加えて、水分が少し減るくらいまで炒める。\n'
                  'ご飯によく合う味で美味しい！！',
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.warning,
                        size: 16.0,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                      text: '',
                    ),
                    TextSpan(
                      text: '：そうでない例（豚キムチの作り方）',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                color: Colors.red.withOpacity(0.2),
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '【材料】\n'
                  '★ 豚こま肉：200g\n'
                  '★ 玉ねぎ：半分\n'
                  '★ にんにく：2片\n'
                  '★ キムチ：200g\n'
                  '○ 塩こしょう：少々\n'
                  '○ 薄力粉：適量\n'
                  '◎ 酒：大さじ1\n'
                  '◎ 醤油：大さじ1\n'
                  '◎ 砂糖：小さじ1\n'
                  '◎ めんつゆ：少々\n\n'
                  '【手順】\n'
                  'まず、★ の材料の下ごしらえを...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
