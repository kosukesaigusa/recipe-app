// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');

// Request module for Slack notification
const request = require('request');

admin.initializeApp();

// 新しいユーザー登録があったことを Slack チャンネルに通知する
// ↓ ヒント＆参考
// exports.onCreateUser = functions.firestore.document('/users/{userId}')
//     .onCreate(async (snapshot, context) => {
//         const user = snapshot.data();
//         const userId = context.params.userId;
//         functions.logger.log("user.userId=%s created a new account", userId);

//         const message = `【通知：新規ユーザー登録】\n• ユーザーID: ${userId}\n• メールアドレス：${user.email}`;

//         request.post({
//             uri: "==== ここにSlackチャンネルのURIを貼る ===", // <-- Slack の Incoming Webhooks で調べる
//             headers: { 'Content-type': 'application/json' },
//             json: { 
//                 'text': message, 
//             }
//         });
// });

// お問い合わせが来たことを Slack チャンネルに通知する
// 上の「onCreateUser」を参考に実装する