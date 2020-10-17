import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class RecipeAddPage extends StatelessWidget {
  final nameController = TextEditingController();
  final contentController = TextEditingController();
  final thumbnailURLController = TextEditingController();

  Widget _h8sizedBox() {
    return SizedBox(
      height: 8,
    );
  }

  final FocusNode _nodeText = FocusNode();

  // カスタムキーボドードのコンフィグ
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText,
          toolbarButtons: [
            //button 1
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text += '【',
                  contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: contentController.text.length)),
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "【",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
            //button 2
            (node) {
              return GestureDetector(
                onTap: () => {
                  contentController.text += '】',
                  contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: contentController.text.length)),
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "】",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      config: _buildConfig(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1.レシピ名：',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 30,
              child: TextField(
                controller: nameController,
                onChanged: (text) {},
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'レシピ名',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 12.0,
                  height: 1.0,
                ),
              ),
            ),
            _h8sizedBox(),
            Text(
              '2.写真',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 150,
              child: Image.network(
                  'https://d3a3a5e2ntl4bk.cloudfront.net/uploads/2020/02/Apple-SteveJobs.jpg'),
            ),
            _h8sizedBox(),
            Text(
              '3.作り方・材料',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            _h8sizedBox(),
            TextFormField(
              controller: contentController,
              focusNode: _nodeText,
              onChanged: (text) {
                // model.content = text;
              },
              minLines: 8,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'レシピをここに記入します',
                border: OutlineInputBorder(),
              ),
            ),
            _h8sizedBox(),
            Text(
              '4.参考にしたレシピ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            _h8sizedBox(),
            Container(
              height: 30,
              child: TextField(
                controller: thumbnailURLController,
                onChanged: (text) {},
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: '参考にしたレシピのURLや書籍名を記入',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 15.0,
                  height: 1.0,
                ),
              ),
            ),
            _h8sizedBox(),
            Text(
              '5.公開',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.blue,
                  value: false,
                  // onChanged: _handleCheckbox,
                ),
                Text(
                  'このレシピをみんなに公開する',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.red,
                  checkColor: Colors.white,
                  value: true,
                  // onChanged: _handleCheckbox,
                ),
                Text(
                  '公開するレシピのガイドラインを読んで同意しました',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text(
                    "わたしのレシピに追加",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
                SizedBox(
                  width: 20,
                ),
                RaisedButton(
                  child: Text(
                    "みんなのレシピに公開",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
