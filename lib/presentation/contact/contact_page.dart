import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/book_list_page.dart';
import 'package:recipe/presentation/contact/contact_model.dart';
class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = '不具合の報告';
    return ChangeNotifierProvider<ContactModel>(
        create: (_) => ContactModel(),
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("お問い合わせ"),
            ),
        //     <<<<<<< Updated upstream
        // body: Text('お問い合わせページ'),
        // =======
    body: Consumer<ContactModel>(builder: (context, model, child) {
      return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(document.data()['title'][0]),
                TextFormField(
                  // controller: mailController,
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
                Container(
                  height: 40,
                  decoration: BoxDecoration(border: Border.all(
                    color: Colors.red,
                    width: 1.0,
                  ),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      // setState(() {
                      //   dropdownValue = newValue;
                      // });
                    },
                    items: <String>['不具合の報告', '機能追加の要望', 'その他']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
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
                  // controller: contactController,
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
    // >>>>>>> Stashed changes
    ),
    );
  }
}