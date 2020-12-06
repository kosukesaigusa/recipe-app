// assert モジュール
const assert = require('assert');

// 設定時にインストールした Firebase のテストのためのライブラリ
const firebase = require('@firebase/rules-unit-testing');

// ファイル読み込みのためのライブラリ
const fs = require('fs');
const { request } = require('http');

// Security Rules の変更をエミュレータ側で都度検知するための記述
const MY_PROJECT_ID = 'dev-recipe-app';

// 対象のルールファイルの明示
const rules = fs.readFileSync('../firestore.rules', 'utf-8');

// 自分のユーザー ID とメールアドレス（仮）
const myUserId = 'my_user_id';
const myEmail = 'my_email@example.com';

// 他人のユーザー ID とメールアドレス（仮）
const theirUserId = 'their_user_id';
const theirEmail = 'their_email@example.com';

// 自分のアカウント認証情報
const myAuth = {
    uid: myUserId, 
    email: myEmail,
};

const theirAuth = {
    uid: theirUserId,
    email: theirEmail,
}

const serverTimestamp = () => firebase.firestore.FieldValue.serverTimestamp();

const myUserFields = {
    createdAt: serverTimestamp(),
    displayName: 'kosukesaigusa',
    iconName: 'icon_2020-11-20 18:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    iconURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/icons%2Ficon_2020-11-20%2018:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=d16a4759-f3d9-493a-ae83-7e5044756767',
    publicRecipeCount: 0,
    recipeCount: 0,
    userId: myAuth.uid
};

const myUserFieldsWithoutUserId = {
    createdAt: serverTimestamp(),
    displayName: 'kosukesaigusa',
    iconName: 'icon_2020-11-20 18:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    iconURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/icons%2Ficon_2020-11-20%2018:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=d16a4759-f3d9-493a-ae83-7e5044756767',
    publicRecipeCount: 0,
    recipeCount: 0,
    // userId: myAuth.uid, 欠落
};

const myAnonymousUserFields = {
    createdAt: serverTimestamp(),
    displayName: 'kosukesaigusa',
    iconName: 'icon_2020-11-20 18:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    iconURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/icons%2Ficon_2020-11-20%2018:18:42.346905_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=d16a4759-f3d9-493a-ae83-7e5044756767',
    publicRecipeCount: 0,
    recipeCount: 0,
    userId: myAuth.uid,
};

// レシピデータのサンプル
const myRecipeDocId = 'DYCp3y7wgFNlQrtEFSl8';
const myRecipeFields = {
    content: '鳥もも肉を1枚買ってきて、必要に応じて皮を取る。全体を均等な一口大の8mmくらいに薄切りして、醤油大さじ3、みりん大さじ1、酒大さじ1、ニンニクチューブ適量の下味に揉み込む。その後10分くらい漬け込んでおく。ボウルから調味液を捨てて、そこに厚くなりすぎない程度の片栗粉を入れる。強めの中火で、両面が良い色になるまで揚げ焼いたら完成。もも肉なのに柔らかく仕上がって美味しい！！',
    createdAt: serverTimestamp(),
    documentId: myRecipeDocId,
    imageName: 'image_2020-11-10 22:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    imageURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/images%2Fimage_2020-11-10%2022:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=31acfef0-2223-4de1-94d8-85dc3006864d',
    isPublic: false,
    name: '薄唐揚げ',
    reference: 'リュウジのバズレシピ',
    thumbnailName: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    thumbnailURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    tokenMap: {'薄唐': true, '唐揚': true, '揚ゲ': true, '鳥モ': true, 'モモ': true, 'モ肉': true, '肉ヲ': true, 'ヲ1': true, '1枚': true, '枚買': true, '買ッ': true, 'ッテ': true, 'テキ': true, 'キテ': true, '必要': true, '要ニ': true, 'ニ応': true, '応ジ': true, 'ジテ': true, 'テ皮': true, '皮ヲ': true, 'ヲ取': true, '取ル': true, '全体': true, '体ヲ': true, 'ヲ均': true, '均等': true, '等ナ': true, 'ナ一': true, '一口': true, '口大': true, '大ノ': true, 'ノ8': true, '8m': true, 'mm': true, 'mク': true, 'クラ': true, 'ライ': true, 'イニ': true, 'ニ薄': true, '薄切': true, '切リ': true, 'リシ': true, 'シテ': true, '醤油': true, '油大': true, '大サ': true, 'サジ': true, 'ジ3': true, 'ミリ': true, 'リン': true, 'ン大': true, 'ジ1': true, '酒大': true, 'ニン': true, 'ンニ': true, 'ニク': true, 'クチ': true, 'チュ': true, 'ュー': true, 'ーブ': true, 'ブ適': true, '適量': true, '量ノ': true, 'ノ下': true, '下味': true, '味ニ': true, 'ニ揉': true, '揉ミ': true, 'ミ込': true, '込ム': true, 'ソノ': true},
    updatedAt: serverTimestamp(),
    userId: myAuth.uid,
};

// お気に入りのレシピデータのサンプル
const myFavoriteRecipeDocId = 'DYCp3y7wgFNlQrtEFSl8';
const myFavoriteRecipeFields = {
    content: '鳥もも肉を1枚買ってきて、必要に応じて皮を取る。全体を均等な一口大の8mmくらいに薄切りして、醤油大さじ3、みりん大さじ1、酒大さじ1、ニンニクチューブ適量の下味に揉み込む。その後10分くらい漬け込んでおく。ボウルから調味液を捨てて、そこに厚くなりすぎない程度の片栗粉を入れる。強めの中火で、両面が良い色になるまで揚げ焼いたら完成。もも肉なのに柔らかく仕上がって美味しい！！',
    createdAt: serverTimestamp(),
    documentId: myFavoriteRecipeDocId,
    imageName: 'image_2020-11-10 22:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    imageURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/images%2Fimage_2020-11-10%2022:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=31acfef0-2223-4de1-94d8-85dc3006864d',
    isPublic: false,
    likedAt: serverTimestamp(),
    name: '薄唐揚げ',
    reference: 'リュウジのバズレシピ',
    thumbnailName: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    thumbnailURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    tokenMap: {'薄唐': true, '唐揚': true, '揚ゲ': true, '鳥モ': true, 'モモ': true, 'モ肉': true, '肉ヲ': true, 'ヲ1': true, '1枚': true, '枚買': true, '買ッ': true, 'ッテ': true, 'テキ': true, 'キテ': true, '必要': true, '要ニ': true, 'ニ応': true, '応ジ': true, 'ジテ': true, 'テ皮': true, '皮ヲ': true, 'ヲ取': true, '取ル': true, '全体': true, '体ヲ': true, 'ヲ均': true, '均等': true, '等ナ': true, 'ナ一': true, '一口': true, '口大': true, '大ノ': true, 'ノ8': true, '8m': true, 'mm': true, 'mク': true, 'クラ': true, 'ライ': true, 'イニ': true, 'ニ薄': true, '薄切': true, '切リ': true, 'リシ': true, 'シテ': true, '醤油': true, '油大': true, '大サ': true, 'サジ': true, 'ジ3': true, 'ミリ': true, 'リン': true, 'ン大': true, 'ジ1': true, '酒大': true, 'ニン': true, 'ンニ': true, 'ニク': true, 'クチ': true, 'チュ': true, 'ュー': true, 'ーブ': true, 'ブ適': true, '適量': true, '量ノ': true, 'ノ下': true, '下味': true, '味ニ': true, 'ニ揉': true, '揉ミ': true, 'ミ込': true, '込ム': true, 'ソノ': true},
    updatedAt: serverTimestamp(),
    userId: myAuth.uid,
};

const myPublicRecipeDocId = 'public_DYCp3y7wgFNlQrtEFSl8';
const myPublicRecipeFields = {
    content: '鳥もも肉を1枚買ってきて、必要に応じて皮を取る。全体を均等な一口大の8mmくらいに薄切りして、醤油大さじ3、みりん大さじ1、酒大さじ1、ニンニクチューブ適量の下味に揉み込む。その後10分くらい漬け込んでおく。ボウルから調味液を捨てて、そこに厚くなりすぎない程度の片栗粉を入れる。強めの中火で、両面が良い色になるまで揚げ焼いたら完成。もも肉なのに柔らかく仕上がって美味しい！！',
    createdAt: serverTimestamp(),
    documentId: myPublicRecipeDocId,
    imageName: 'image_2020-11-10 22:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg',
    imageURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/images%2Fimage_2020-11-10%2022:41:16.072893_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=31acfef0-2223-4de1-94d8-85dc3006864d',
    isPublic: true,
    name: '薄唐揚げ',
    reference: 'リュウジのバズレシピ',
    thumbnailName: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    thumbnailURL: 'https://firebasestorage.googleapis.com/v0/b/dev-recipe-app.appspot.com/o/thumbnails%2Fthumbnail_2020-11-10%2022:41:18.681737_wxPbadcN40SIURVpXaxS9WsEoaK2.jpg?alt=media&token=97364ba2-57f9-47c7-94e8-5ae738e288f3',
    tokenMap: {'薄唐': true, '唐揚': true, '揚ゲ': true, '鳥モ': true, 'モモ': true, 'モ肉': true, '肉ヲ': true, 'ヲ1': true, '1枚': true, '枚買': true, '買ッ': true, 'ッテ': true, 'テキ': true, 'キテ': true, '必要': true, '要ニ': true, 'ニ応': true, '応ジ': true, 'ジテ': true, 'テ皮': true, '皮ヲ': true, 'ヲ取': true, '取ル': true, '全体': true, '体ヲ': true, 'ヲ均': true, '均等': true, '等ナ': true, 'ナ一': true, '一口': true, '口大': true, '大ノ': true, 'ノ8': true, '8m': true, 'mm': true, 'mク': true, 'クラ': true, 'ライ': true, 'イニ': true, 'ニ薄': true, '薄切': true, '切リ': true, 'リシ': true, 'シテ': true, '醤油': true, '油大': true, '大サ': true, 'サジ': true, 'ジ3': true, 'ミリ': true, 'リン': true, 'ン大': true, 'ジ1': true, '酒大': true, 'ニン': true, 'ンニ': true, 'ニク': true, 'クチ': true, 'チュ': true, 'ュー': true, 'ーブ': true, 'ブ適': true, '適量': true, '量ノ': true, 'ノ下': true, '下味': true, '味ニ': true, 'ニ揉': true, '揉ミ': true, 'ミ込': true, '込ム': true, 'ソノ': true},
    updatedAt: serverTimestamp(),
    userId: myAuth.uid,
};

// お問い合わせデータのサンプル
const contactDocId = 'public_DYCp3y7wgFNlQrtEFSl8';
const contactFields = {
    userId: myAuth.uid,
    email: myAuth.email,
    category: '不具合の報告',
    content: 'あんなこんな不具合がありました。',
    createdAt: serverTimestamp(),
};

// 対象の Firestore DB の定義
function getFirestore(auth) {
    // プロジェクト ID と 認証情報を入力して、Cloud Firestore のインスタンスを取得
    return firebase.initializeTestApp({projectId: MY_PROJECT_ID, auth: auth}).firestore();
}

// テスト郡の実行前
before(async () => {
    await firebase.loadFirestoreRules({projectId: MY_PROJECT_ID, rules});
});

// ひとつひとつのテストの実行前
beforeEach(async () => {
    await firebase.clearFirestoreData({projectId: MY_PROJECT_ID});
});

describe('ユニットテストの実行', () => {

    describe('/users', () => {
        describe('get', () => {
            it('[Fail] 認証が済んでいないのでユーザーデータを取得できない', async () => {
                const db = getFirestore(null);  // Firestore DB にサインインせずにアクセス
                const myUserDoc = db.collection('users').doc(myUserId);
                await firebase.assertFails(myUserDoc.get());
            });
            it('[Success] 認証が済んでいるので、誰でもユーザーデータは取得できる（Email は含まない）', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);  // 自身のユーザードキュメント
                await firebase.assertSucceeds(myUserDoc.get());
            });
        });
    
        describe('create', async () => {
            it('[Fail] 他人のユーザードキュメントは作成できない', async () => {
                const db = getFirestore(myAuth);
                const theirUserDoc = db.collection('users').doc(theirUserId); // 他人のユーザードキュメント
                await firebase.assertFails(theirUserDoc.set(myUserFields));
            });
            it('[Fail] email フィールドが欠落しているので、ユーザードキュメントは作成できない', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await firebase.assertFails(myUserDoc.set(myUserFieldsWithoutUserId));
            });
            it('[Success] 本人のユーザードキュメントは作成できる', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await firebase.assertSucceeds(myUserDoc.set(myUserFields));
            });
            it('[Success] 本人のユーザードキュメントは匿名でも作成できる', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await firebase.assertSucceeds(myUserDoc.set(myAnonymousUserFields));
            });
        });

        describe('update', async () => {
            it('[Fail] createdAt が変更されているので更新を許さない', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await myUserDoc.set(myUserFields);
                await firebase.assertFails(myUserDoc.update({createdAt: serverTimestamp()}));
            });
            it('[Fail] user ID が変更されているので更新を許さない', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await myUserDoc.set(myUserFields);
                await firebase.assertFails(myUserDoc.update({userId: '更新したユーザー ID'}));
            });
            it('[Success] ユーザーの displayName を変更する', async () => {
                const db = getFirestore(myAuth);
                const myUserDoc = db.collection('users').doc(myUserId);
                await myUserDoc.set(myUserFields);
                await firebase.assertSucceeds(myUserDoc.update({displayName: '更新したディスプレイネーム'}));
            });
        });
    });

    describe('/users/{userId}/user_info', () => {
        describe('get', () => {
            it('[Fail]', async () => {
            });
            it('[Success]', async () => {
            });
        });
    
        describe('create', async () => {
            it('[Fail]', async () => {
            });
            it('[Success]', async () => {
            });
        });

        describe('update', async () => {
            it('[Fail]', async () => {
            });
            it('[Success]', async () => {
            });
        });
    });

    describe('/users/{userId}/recipes', () => {
        describe('read', async () => {
            it('[Success] 本人のレシピコレクションは取得できる', async () => {
                const db = getFirestore(myAuth);
                const myRecipesCollection = db.collection('users')
                .doc(myUserId)
                .collection('recipes')
                await firebase.assertSucceeds(myRecipesCollection.get());
            });
        });

        describe('create', async () => {
            it('[Fail] 他人のレシピは作成できない', async () => {
                const db = getFirestore(theirAuth);
                const myRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('recipes')
                .doc(myRecipeDocId);
                await firebase.assertFails(myRecipeDoc.set(myRecipeFields));
            });
            it('[Success] 本人はレシピを作成できる', async () => {
                const db = getFirestore(myAuth);
                const myRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('recipes')
                .doc(myRecipeDocId);
                await firebase.assertSucceeds(myRecipeDoc.set(myRecipeFields));
            });
        });

        describe('update', async () => {
            it('[Success] 本人はレシピを更新できる', async () => {
                const db = getFirestore(myAuth);
                const myRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('recipes')
                .doc(myRecipeDocId);
                await myRecipeDoc.set(myRecipeFields);
                await firebase.assertSucceeds(myRecipeDoc.update({
                    name: '更新したレシピ名', 
                    updatedAt: serverTimestamp(),
                }));
            });
        });

        describe('delete', async () => {
            it('[Success] 本人はレシピを削除できる', async () => {
                const db = getFirestore(myAuth);
                const myRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('recipes')
                .doc(myRecipeDocId);
                await myRecipeDoc.set(myRecipeFields);
                await firebase.assertSucceeds(myRecipeDoc.delete());
            });
        });
        
    });

    describe('/users/{userId}/favorite_recipes', () => {
        describe('read', async () => {
        });

        describe('create', async () => {
            it('[Fail] 他人のお気に入りのレシピは作成できない', async () => {
                const db = getFirestore(theirAuth);
                const myFavoriteRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('favorite_recipes')
                .doc(myFavoriteRecipeDocId);
                await firebase.assertFails(myFavoriteRecipeDoc.set(myFavoriteRecipeFields));
            });
            it('[Success] 本人はお気に入りのレシピを作成できる', async () => {
                const db = getFirestore(myAuth);
                const myFavoriteRecipeDoc = db.collection('users')
                .doc(myUserId)
                .collection('favorite_recipes')
                .doc(myFavoriteRecipeDocId);
                await firebase.assertSucceeds(myFavoriteRecipeDoc.set(myFavoriteRecipeFields));
            });
        });

        describe('update', async () => {

        });

        describe('delete', async () => {

        });
    });

    describe('/public_recipes', () => {
        describe('read', async () => {

        });

        describe('create', async () => {
            it('[Fail] 他人の ID でお気に入りのレシピは作成できない', async () => {
                const db = getFirestore(theirAuth);
                const myPublicRecipeDoc = db.collection('public_recipes').doc(myPublicRecipeDocId);
                await firebase.assertFails(myPublicRecipeDoc.set(myPublicRecipeFields));
            });
            it('[Success] 自分の ID でお気に入りのレシピを作成できる', async () => {
                const db = getFirestore(myAuth);
                const myPublicRecipeDoc = db.collection('public_recipes').doc(myPublicRecipeDocId);
                await firebase.assertSucceeds(myPublicRecipeDoc.set(myPublicRecipeFields));
            });
        });

        describe('update', async () => {
            it('[Success] 本人は公開されたレシピを更新できる', async () => {
                const db = getFirestore(myAuth);
                const myPublicRecipeDoc = db.collection('public_recipes').doc(myPublicRecipeDocId);
                await myPublicRecipeDoc.set(myPublicRecipeFields)
                await firebase.assertSucceeds(myPublicRecipeDoc.update({
                    name: '更新したレシピ名',
                    isPublic: false, // 更新状態を引っ込めることもできる
                    updatedAt: serverTimestamp(),
                }));
            });
        });

        describe('delete', async () => {
            it('[Fail] 他人が公開したレシピは削除できない', async () => {
                // わたしがレシピを公開
                const myDB = getFirestore(myAuth);
                const myPublicRecipeDoc = myDB.collection('public_recipes').doc(myPublicRecipeDocId);
                await myPublicRecipeDoc.set(myPublicRecipeFields)
                // 他人がそのレシピを参照
                const theirDB = getFirestore(theirAuth);
                const theirPublicRecipeDoc = theirDB.collection('public_recipes').doc(myPublicRecipeDocId);
                // await firebase.assertSucceeds(theirPublicRecipeDoc.get());
                // 他人がそのれレシピの削除を試みる
                await firebase.assertFails(theirPublicRecipeDoc.delete());
            });
            it('[Success] 本人が公開したレシピは削除できる', async () => {
                const db = getFirestore(myAuth);
                const myPublicRecipeDoc = db.collection('public_recipes').doc(myPublicRecipeDocId);
                await myPublicRecipeDoc.set(myPublicRecipeFields)
                await firebase.assertSucceeds(myPublicRecipeDoc.delete());
            });
        });
    });

    describe('contacts', () => {
        describe('create', async () => {
            it('[Success] お問い合わせを送信できる', async () => {
                const db = getFirestore(myAuth);
                const contactDoc = db.collection('contacts').doc(contactDocId);
                await firebase.assertSucceeds(contactDoc.set(contactFields));
            });
        });
    });

});

// テスト郡の実行後
// after(async () => {
//     await firebase.clearFirestoreData({projectId: MY_PROJECT_ID});
// });