import 'package:flutter/material.dart';

class GuidelinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36.0),
        child: AppBar(
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
            'ガイドライン',
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
              Center(
                child: Text(
                  '公開するレシピのガイドライン',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '「シンプルなレシピ」は、レシピをより簡単に記録・検索・調理するのに'
                '役立つ価値を提供するモバイルアプリです。',
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'シンプルなレシピには、',
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                '• 自分用の記録である「わたしのレシピ」\n'
                '• 他のユーザーに公開する「みんなのレシピ」',
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                'の 2 種類の異なるレシピの公開範囲が存在します。',
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '「みんなのレシピ」に公開する際には、必ず下記のガイドラインに目を通し、'
                'ご理解・ご承諾の上でご利用ください。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'レシピを公開する際のマナー',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('一般に、レシピそのものは著作物には当たらないと言われていますが、レシピ本やレシピブログに書かれた文章など、'
                  '他人が考案・発表したレシピをそのまま転載するような行為は行わないでください。'),
              SizedBox(
                height: 8.0,
              ),
              Text('他人のレシピを参考にした場合は、その参考元の情報（レシピ名や書籍名、URL など）を'
                  '必ず「参考にしたレシピ」欄に記入してください。'),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'また、レシピを公開する際には、他のユーザーが読んで分かりやすい文章や構成を心がけましょう。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'レシピに掲載する写真',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '「シンプルなレシピ」では、レシピにつき 1 枚の写真を一緒に投稿することができます。'
                'レシピに関係のない写真やイラスト、著作権の観点から問題のある写真などは掲載しないでください。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'レシピの書き方のコツ',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('「シンプルなレシピ」は、レシピを閲覧する際に、調理中の汚れた手で画面をスクロールする必要がないように、'
                  '従来的なレシピ管理サービスのように、多くの見栄えの良い写真をレシピ中に挿入したり、'
                  '材料と作り方を別々の場所に整理して掲載したりするのではなく、「作り方・材料」欄に、一連の文章として'
                  'レシピの手順が材料とともに紹介される状況を想定しています。'),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '「作り方・材料」欄には、最大 1000 文字の文字数制限も設けていますので、'
                '冗長な表現や不要な記号の使用などを避け、簡潔で分かりやすいレシピにまとめてください。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'その他の責任など',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'レシピを公開するに当たっては、上記のガイドラインに従った上で、他の利用者に不快感を与えたり、'
                '特定の個人や企業を誹中傷するような行為、その他の運営を妨げたりするような行為は行わないでください。'
                '状況によっては、アカウントの停止やレシピの削除などの対応が行われることがあります。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  '2020 年 11 月 16 日 最終改定',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
