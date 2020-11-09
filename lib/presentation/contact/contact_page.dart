import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/presentation/contact/contact_model.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactModel>(
      create: (_) => ContactModel()..fetchContact(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("お問い合わせ"),
        ),
        body: Consumer<ContactModel>(
          builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    readOnly: true,
                    initialValue: model.mail,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Eメール（編集不可）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'お問い合わせカテゴリー',
                      border: OutlineInputBorder(),
                      errorText: model.errorCategory == ''
                          ? null
                          : model.errorCategory,
                    ),
                    value: model.category,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    items: ['', '不具合の報告', '機能追加の要望', 'その他']
                        .map((label) => DropdownMenuItem(
                              child: Text(label),
                              value: label,
                            ))
                        .toList(),
                    onChanged: (text) {
                      model.changeCategory(text);
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    onChanged: (text) {
                      model.changeContent(text);
                    },
                    minLines: 10,
                    maxLines: 15,
                    decoration: InputDecoration(
                      labelText: '本文',
                      border: OutlineInputBorder(),
                      errorText:
                          model.errorContent == '' ? null : model.errorContent,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: RaisedButton(
                      child: Text('お問い合わせを送信'),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: model.isCategoryValid && model.isContentValid
                          ? () async {
                              try {
                                await model.submitForm();
                                await showTextDialog(context, 'お問い合わせを送信しました。');
                              } catch (e) {
                                await showTextDialog(context, 'エラーが発生しました。');
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
