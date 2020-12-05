// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');

// Request module for Slack notification
const request = require('request');

admin.initializeApp();

// 新しいユーザー登録があったことを Slack チャンネルに通知する
exports.onCreateUser = functions.firestore.document('/users/{userId}')
    .onCreate(async (snapshot, context) => {
        const user = snapshot.data();
        const userId = context.params.userId;
        functions.logger.log("user.userId=%s created a new user", userId);

        const message = `【通知：新規ユーザー登録】\n• ユーザーID：${userId}\n• メールアドレス：${user.email}`;

        request.post({
            uri: "https://hooks.slack.com/services/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",
            headers: { 'Content-type': 'application/json' },
            json: { 
                'text': message, 
            }
        });
});

// お問い合わせが来たことを Slack チャンネルに通知する
exports.onCreateContact = functions.firestore.document('/contacts/{contactId}')
    .onCreate(async (snapshot, context) => {
        const contact = snapshot.data();
        const contactId = context.params.contactId;
        functions.logger.log("contact.contactId=%s created a new contact", userId);
        const message = `【通知：お問い合わせ】\n• お問い合わせID：${contactId}\n • ユーザーID：${contact.userId}\n• メールアドレス：${contact.email}\n• カテゴリー：${contact.category}\n• 内容：${contact.content}`;

        request.post({
            uri: "https://hooks.slack.com/services/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",
            headers: { 'Content-type': 'application/json' },
            json: { 
                'text': message, 
            }
        });
});