# シンプルなレシピ

Flutter & Firebase 製のレシピ管理・投稿アプリ

* [iOS 版 App Store リンク](https://apps.apple.com/jp/app/%E3%82%B7%E3%83%B3%E3%83%97%E3%83%AB%E3%81%AA%E3%83%AC%E3%82%B7%E3%83%94/id1543341359?l=ja)
* Android 版（Google Play Store へ申請中）

| 検索画面 | レシピ画面 | 調理時の閲覧画面 |
| --- | --- | --- |
|![mock-top](./information/screenshots/mock-top.png "mock-top")|![mock-recipe](./information/screenshots/mock-recipe.png "mock-recipe")|![mock-recipe-detail](./information/screenshots/mock-recipe-detail.png "mock-recipe-detail")|

## シンプルなレシピについて

本リポジトリは、[KBOY の Flutter 大学](https://www.youtube.com/channel/UCReuARgZI-BFjioA8KBpjsw) のオンラインサロンのメンバー数名で行った、2020年10月にスタートした共同開発プロジェクトのひとつです。

「シンプルなレシピ」は、主たる開発者/プロダクトオーナーである [@KosukeSaigusa](https://github.com/KosukeSaigusa)（本リポジトリのオーナー）が日々色々なツールを試しながら行っていた料理の記録を、シンプルな操作性と UI によって投稿・管理し、調理時の汚れたり濡れたりした手で画面をスクロールする必要なく、作り方を参照しながら料理をするためのアプリケーションを作成したいという考えで開発されました。

## 機能や実装内容の一覧

Flutter, Firebase, Firebase Authentification, Cloud Storage, Cloud Functions, Docker などを使用して、下記のようなアプリの各機能等の実装を行いました。

* アプリの UI の実装に必要な様々な Flutter ウィジェットの実装
* `Provider`, `ChangeNotifier` を用いた `Stateless` ウィジェットによる状態管理
* `development`, `staging`, `production` の 3 つの Flavor と `debug`, `release` の 2 つのビルドモードに応じた各環境および Firebase プロジェクトで、 iOS, Android の両方のビルドを行うための環境構築
* 認証機能 (Firebase Authentification)
* 画像を含むレシピの投稿, 更新, 削除機能
* 投稿する画像のトリミング・圧縮機能
* レシピの検索機能（N-gram を用いたサードパーティを使わない Firestore による全文検索機能の実装）
* レシピの公開・非公開の状態管理機能
* レシピの無限スクロール機能
* レシピのお気に入り機能（Flutter の Stream を用いたお気に入りステイタスの監視を含む）
* レシピの更新時などのバッチ処理の機能
* 認証認可・スキーマ検証・バリデーションに分けた Firestore Security Rules の実装およびテストの実装
* Cloud Storage の Security Rules の実装
* Docker を用いた Firebase CLI の環境構築
* ユーザー登録やお問い合わせを管理者に通知する機能 (Cloud Functions)

## 本リポジトリを Flutter, Firebase の学習の参考にする方へ

* アプリを構成する主なコードは [`recipe-app/lib`](https://github.com/KosukeSaigusa/recipe-app/tree/main/lib) 以下に配置されています。
* 環境構築は、[`recipe-app/information/setup/README.md`](https://github.com/KosukeSaigusa/recipe-app/tree/main/information/setup) を参考に、ご自身で Firebase プロジェクトを `development`, `staging`, `production` の 3 つに分けて作成し、必要な箇所は各人が決める Bundle ID や Pckage ID で適宜読み替えて行って下さい。
* Firestore の DB（コレクション）の構成およびエンティティの概要は [`recipe-app/information/schema/schema.yaml`](https://github.com/KosukeSaigusa/recipe-app/blob/main/information/schema/schema.yaml) を参考にして下さい。
* Docker を用いたローカルでの Firebase CLI の環境構築は、[`recipe-app/firebase/README.md`](https://github.com/KosukeSaigusa/recipe-app/tree/main/firebase) を参考にして下さい。
* Firestore の Security Rules は、[`recipe-app/firebase/firestore.rules`](https://github.com/KosukeSaigusa/recipe-app/blob/main/firebase/firestore.rules) を参考にして下さい。