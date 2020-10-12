import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/book_list_page.dart';
import 'package:recipe/presentation/contact/contact_model.dart';
import 'package:recipe/presentation/signup/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatelessWidget {
  CollectionReference users = FirebaseFirestore.instance.collection('contacts');
  final mailController = TextEditingController();
  final categoryController = TextEditingController();
  final contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactModel>(
      create: (_) => ContactModel(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("お問い合わせ"),
        ),
        body: Consumer<ContactModel>(builder: (context, model, child) {
          return Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(document.data()['title'][0]),
                TextFormField(
                  controller: mailController,
                  readOnly: true,
                  onChanged: (text) {
                    // model.mail = text.trim();
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Eメール',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  // controller: categoryController,
                  onChanged: (text) {
                    model.contactTitle = text;
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'お問い合わせのカテゴリー',
                    border: OutlineInputBorder(),
                  ),
                ),
                // TextField(
                //   onChanged: (text){
                //     model.contactTitle = text;
                //   },
                // ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: contactController,
                  onChanged: (text) {
                    // model.contact = text;
                  },
                  minLines: 15,
                  maxLines: 20,
                  decoration: InputDecoration(
                    labelText: '本文',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    child: Text('お問い合わせを送信'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      await model.contactToFirebase();
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    child: Text('質問list'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookList()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ));
        }),
      ),
    );
  }
}

_showTextDialog(context, message) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
