// assert モジュール
const assert = require('assert');

// 設定時にインストールした Firebase のテストのためのライブラリ
const firebase = require('@firebase/rules-unit-testing');

// ファイル読み込みのためのライブラリ
const fs = require('fs');

// Security Rules の変更をエミュレータ側で都度検知するための記述
const MY_PROJECT_ID = "dev-recipe-app";

// 対象のルールファイルの明示
const rules = fs.readFileSync('../firestore.rules', 'utf-8');

// 自分のユーザー ID とメールアドレス（仮）
const myId = "user_me";
const myEmail = "my_email@example.com";

// 他人のユーザー ID とメールアドレス（仮）
const theirId = "user_them";
const theirEmail = "their_email@example.com";

// 自分のアカウント認証情報
const myAuth = {
    uid: myId, 
    email: myEmail,
};

// 対象の Firestore DB の定義
function getFirestore(auth) {
    // プロジェクト ID と 認証情報を入力して、Cloud Firestore のインスタンスを取得
    return firebase.initializeTestApp({projectId: MY_PROJECT_ID, auth: auth}).firestore();
}

describe("ユーザーデータの取得", () => {
    it("[Fail] 他人のユーザードキュメントは取得できない", async () => {
        // 対象の Firestore DB の定義
        const db = getFirestore(myAuth);
        // テスト対象の Document Reference
        const testDoc = db.collection("users").doc(theirId);
        // テストで確認する動作
        await firebase.assertFails(testDoc.get());
    });

    it("[Success] 本人のユーザードキュメントは取得できる", async () => {
        // 対象の Firestore DB の定義
        const db = getFirestore(myAuth);
        // テスト対象の Document Reference
        const testDoc = db.collection("users").doc(myId);
        // テストで確認する動作
        await firebase.assertSucceeds(testDoc.get());
    });
});