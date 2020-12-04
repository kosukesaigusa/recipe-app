import 'package:flutter/material.dart';

class UserPolicyPage extends StatelessWidget {
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
            '利用規約',
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
                  'シンプルなレシピ 利用規約',
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
                '本利用規約について',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('「シンプルな利用規約」（以下「本利用規約」といいます。）は、'
                  'シンプルなレシピ（以下「本アプリケーション」といいます。）において提供する'
                  'すべてのサービス（以下「本サービス」といいます。）の利用条件を定めるものです。'
                  '本サービスをご利用される場合には、利用者は本利用規約に同意したものとみなされ、'
                  '本利用規約を内容とする本サービスの利用契約が成立したものとみなします。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'ユーザー登録',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '本サービスはメールアドレスを登録せずに利用することも可能ですが、'
                'アプリケーション内におけるユーザーの認証情報（セッション）が途切れた場合や、'
                'アプリケーションのアンインストール時、端末の変更などの場合に、'
                '自身が記録したレシピ情報が引き継がれないことがあります。'
                '自身のレシピ情報をユーザー情報とともに保管することやその他の機能をすべて利用するためには、'
                'メールアドレスとパスワードを用いたユーザー登録が必要です。',
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '個人情報の取り扱いなど',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('本サービスの運営者は、別途定める「サービスプライバシーポリシー」で示す通り、'
                  'ユーザー登録の目的で集めたメールアドレスの情報を、ログイン時の認証の目的および'
                  'アプリケーションに必要な機能を提供する目的のみに使用し、'
                  '第三者に提供することなく適切に取り扱うものとします。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '利用環境の整備',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('利用者は、本サービスを利用するために必要な通信機器、ソフトウェア'
                  'その他これらに付随して必要となる全ての機器を、自己の費用と責任において準備し、'
                  '利用可能な状態に置くものとします。また、本サービスの利用にあたっては、'
                  '自己の費用と責任において、利用者が任意に選択し、'
                  '電気通信サービスまたは電気通信回線を経由してインターネットに接続するものとします。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '自己責任の原則',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('利用者は、利用者自身の自己責任において本サービスを利用するものとし、'
                  '本サービスを利用してなされた一切の行為およびその結果について'
                  'その責任を負うものとします。また、利用者は、本サービスの利用に際し、'
                  '他の利用者その他の第三者および本サービスの運営者に損害'
                  'または不利益を与えた場合、自己の責任と費用において'
                  'これを解決するものとします。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '知的財産権など',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('利用者が送信（発信）したコンテンツが、'
                  '第三者への権利侵害や迷惑行為に該当する場合、'
                  'それらに起因または関連して生じたすべてのクレームや請求について、'
                  '利用者の責任と費用においてこれを解決するものとします。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '禁止事項',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('利用者は、本サービスの利用に際して、以下の行為を行ってはならないものとします。'),
              SizedBox(
                height: 4.0,
              ),
              Text(
                '• レシピに関係のないコンテンツや画像を投稿する行為\n'
                '• 本サービスの運営者、他の利用者もしくはその他の第三者'
                '（以下「他者」といいます。）の著作権、'
                '商標権等の知的財産権を侵害する行為、または侵害するおそれのある行為\n'
                '• 他者の財産、プライバシーもしくは肖像権を侵害する行為、または侵害するおそれのある行為\n'
                '• 特定の個人の個人情報を提供する行為\n'
                '• 他者を差別、または誹謗中傷したり、他者の名誉や信用を毀損したりする行為\n'
                '• 同様の問い合わせの繰り返しなどを過度に行い、または義務や理由のないことを強要し、'
                'サービスの運営者の運営業務に著しく支障を来たす行為\n',
              ),
              SizedBox(
                height: 4.0,
              ),
              Text('また、以上の禁止事項に該当する行為や、'
                  '本利用規約の内容に反する行為が行われているとサービス運営者が判断するユーザーは、'
                  'サービス運営者によりアカウントの利用停止や'
                  'そのコンテンツの削除などの対応が行われることがあります。'),
              SizedBox(
                height: 16.0,
              ),
              Text(
                '他者が投稿した不適切なコンテンツについて',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('他者が公開設定にしたレシピコンテンツである「みんなのレシピ」には、'
                  '不適切な行為を行うユーザーの存在によって、'
                  'レシピとは関係のない、またはその他の不適切なコンテンツが含まれる可能性があります。'
                  '本サービスを利用する前提として、そのようなコンテンツを目にする可能性があることを'
                  '了承しているものとします。'
                  'ただし、そのような不適切なコンテンツを見つけた場合には、'
                  '当該レシピ画面右上の通報用のアイコンボタンより、該当するコンテンツの情報を'
                  'サービス運営にお知らせ下さい。可及的速やかに内容を確認し、サービス運営者が'
                  '必要と判断した場合には、該当するコンテンツを削除したり、該当するコンテンツを'
                  '送信したユーザーを利用停止にしたりする対応を行います。'),
              SizedBox(
                height: 16.0,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  '2020 年 12 月 04 日 最終改定',
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
