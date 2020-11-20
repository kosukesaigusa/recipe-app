// assert モジュール
const assert = require('assert');

// 設定時にインストールした Firebase のテストのためのライブラリ
const firebase = require('@firebase/rules-unit-testing');

// ファイル読み込みのためのライブラリ
const fs = require('fs');
const { request } = require('http');

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

const serverTimestamp = () => firebase.firestore.FieldValue.serverTimestamp();

// レシピドキュメントデータ
const recipe_content = "まず豚こま肉を200g程度、塩胡椒と薄力粉でコーティングして下準備する。ニンニクは2片ほどを荒みじん切り、玉ねぎ半分を薄めのスライスにしておく。 温めたフライパンにニンニクを入れて火を通し、柴犬色になったら肉をよく広げながら入れる。全体に火が通ってきたら玉ねぎを入れて、透明になるまで炒める。そこにキムチを投入して、酒大さじ1、醤油小さじ1、砂糖小さじ1、めんつゆ少々を加えて、水分が少し減るくらいまで炒める。 ご飯によく合う味で美味しい！！";
const recipe_documentId = "DYCp3y7wgFNlQrtEFSl8";
const recipe_imageURL = "https://img.cpcdn.com/recipes/597693/840x1461s/3961a206a888b9997f627487663ab3a4?u=125911&p=1246605171";
const recipe_imageName = "image_2020-11-10 22:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg"
const recipe_isPublic = true;
const recipe_name = "【36】 わたしの豚キムチ";
const recipe_reference = "リュウジのバズレシピ";
const recipe_thumbnailURL = "https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3";
const recipe_thumbnailName = "thumbnail_2020-11-10 22:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg";
const recipe_tokenMap = {"豚キ": true};



// 対象の Firestore DB の定義
function getFirestore(auth) {
    // プロジェクト ID と 認証情報を入力して、Cloud Firestore のインスタンスを取得
    return firebase.initializeTestApp({projectId: MY_PROJECT_ID, auth: auth}).firestore();
}

// テスト郡の実行前
before(async () => {
    await firebase.loadFirestoreRules({projectId: MY_PROJECT_ID, rules});
});

// 各テストの実行前
beforeEach(async () => {
    await firebase.clearFirestoreData({projectId: MY_PROJECT_ID});
});

describe("ユニットテストの実行", () => {

    describe("ユーザーデータの取得", () => {
        it("[Fail] 他人のユーザーデータは取得できない", async () => {
            // 対象の Firestore DB の定義
            const db = getFirestore(myAuth);
            // テスト対象の Document Reference
            const testDoc = db.collection("users").doc(theirId);
            // テストで確認する動作
            await firebase.assertFails(testDoc.get());
        });

        it("[Success] 本人のユーザーデータは取得できる", async () => {
            // 対象の Firestore DB の定義
            const db = getFirestore(myAuth);
            // テスト対象の Document Reference
            const testDoc = db.collection("users").doc(myId);
            // テストで確認する動作
            await firebase.assertSucceeds(testDoc.get());
        });
    });

    
    describe("ユーザードキュメントの作成", async () => {
        it("[Fail] 他人のユーザードキュメントは作成できない", async () => {
            const db = getFirestore(myAuth);
            const testDoc = db.collection("users").doc(theirId); // 他人のユーザードキュメント
            await firebase.assertFails(testDoc.set({
                createdAt: serverTimestamp(),
                email: myAuth.email,
                userId: myAuth.uid
            }));
        });

        it("[Fail] リクエストの中に email フィールドが存在しないので、ユーザードキュメントは作成できない", async () => {
            const db = getFirestore(myAuth);
            const testDoc = db.collection("users").doc(myId);
            await firebase.assertFails(testDoc.set({
                createdAt: serverTimestamp(),
                userId: myAuth.uid,
                // email: myAuth.email,
                // email がフィールドに含まれない
            }));
        });

        it("[Success] 本人のユーザードキュメントは作成できる", async () => {
            const db = getFirestore(myAuth);
            const testDoc = db.collection("users").doc(myId);
            await firebase.assertSucceeds(testDoc.set({
                createdAt: serverTimestamp(),
                email: myAuth.email,
                userId: myAuth.uid
            }));
        });
    });

        describe("わたしのレシピ", async () => {
            it("[Fail] 他人のレシピ_は作成できない", async () => {
                const db = getFirestore(myAuth);
                const testDoc = db.collection("users").doc(theirId)
                                .collection("recipes").doc(recipe_documentId);
                await firebase.assertFails(testDoc.set({
                }));
            });

            it("[Success] 本人は、レシピを作成できる", async () => {
                const db = getFirestore(myAuth);
                const testDoc = db.collection("users").doc(myId)
                                .collection("recipes").doc(recipe_documentId);
                await firebase.assertSucceeds(testDoc.set({
                   content: recipe_content,
                   createdAt: serverTimestamp(),
                   documentId: recipe_documentId,
                   imageURL: recipe_imageURL,
                   imageName: recipe_imageName,
                   isPublic: recipe_isPublic,
                   name: recipe_name,
                   reference: recipe_reference,
                   thumbnailURL: recipe_thumbnailURL,
                   thumbnailName: recipe_thumbnailName,
                   tokenMap: recipe_tokenMap,
                   updatedAt: serverTimestamp(),
                   userId: myAuth.uid,
                }));
                await firebase.assertFails(testDoc.set({
                    content:123,
                    updatedAt: serverTimestamp(),
                }));
            });

            it("[Success] 本人は、レシピを更新できる", async () => {
                const db = getFirestore(myAuth);
                const testDoc = db.collection("users").doc(myId)
                                .collection("recipes").doc(recipe_documentId);
                await firebase.assertFails(testDoc.update({
                    createdAt: serverTimestamp(),
                    
                }));
            });
        });



              

    // describe("みんなのレシピ", async () => {

    //     it("[Success] すべてのレシピが閲覧できる", async () => {
    //         const db = getFirestore(myAuth);
    //         const testDoc = db.collection("public_recipes").doc();                
    //         await firebase.assertSucceeds(testDoc.get({
    //         }));
    //     });

    //     it("[Fail] 他人はレシピを作成できない", async () => {
    //         const db = getFirestore(myAuth);
    //         const testDoc = db.collection("public_recipes").doc(theirId)
    //                         .collection("recipes").doc(theirId);
    //         await firebase.assertFails(testDoc.set({
    //         }));
    //     });

        // it("[Success] 本人はレシピを作成できる", async () => {
        //     const db = getFirestore(myAuth);
        //     const testDoc = db.collection("public_recipes").doc(myId);                
        //     await firebase.assertSucceeds(testDoc.set({
        //     }));
        // });

        // it("[Fail] 他人はレシピを更新できない", async () => {
        //     const db = getFirestore(myAuth);
        //     const testDoc = db.collection("public_recipes").doc(theirId)
        //                     .collection("recipes").doc(theirId);
        //     await firebase.assertFails(testDoc.update({
        //     }));
        // });

        // });




    });

// テスト郡の実行後
after(async () => {
    await firebase.clearFirestoreData({projectId: MY_PROJECT_ID});
});