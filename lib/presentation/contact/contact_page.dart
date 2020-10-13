import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_model.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String dropdownValue;
    final emailController = TextEditingController();
    final categoryController = TextEditingController();
    final contentController = TextEditingController();

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
                  controller: emailController,
                  // readOnly: true,
                  onChanged: (text) {
                    model.email = text;
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
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue = "不具合の報告",
                      decoration: InputDecoration.collapsed(),
                      icon: Icon(Icons.arrow_drop_down_outlined),
                      iconSize: 24,
                      elevation: 16,
                      items: ["不具合の報告", "機能追加の要望", "その他"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (text) {
                        model.category = text;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: contentController,
                  onChanged: (text) {
                    model.content = text;
                  },
                  minLines: 10,
                  maxLines: 15,
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
                      try {
                        await model.addContactToFirebase();
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('お問い合わせを送信しました！'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    emailController.clear();
                                    categoryController.clear();
                                    contentController.clear();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(e.toString()),
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
                    },
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // SizedBox(
                //   width: double.infinity,
                //   height: 50,
                //   child: RaisedButton(
                //     child: Text('質問list'),
                //     color: Colors.blue,
                //     textColor: Colors.white,
                //     onPressed: () async {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => BookList()),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ));
        }),
      ),
    );
  }
}
