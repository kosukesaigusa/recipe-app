import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/presentation/display_name_update/display_name_update_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class DisplayNameUpdatePage extends StatelessWidget {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DisplayNameUpdateModel>(
      create: (_) => DisplayNameUpdateModel(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text(
              '表示名の変更',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.close,
                size: 20.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Consumer<DisplayNameUpdateModel>(
          builder: (context, model, child) {
            this._focusNode.addListener(() {
              model.isFocused = this._focusNode.hasFocus;
              model.changeFocus(this._focusNode.hasFocus);
            });
            return Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        focusNode: this._focusNode,
                        autofocus: true,
                        onChanged: (text) {
                          model.changeDisplayName(text);
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          errorText: model.errorDisplayName == ''
                              ? null
                              : model.errorDisplayName,
                          labelText: '新しい表示名',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      model.isFocused &&
                              model.newDisplayName.length >= 10 &&
                              model.newDisplayName.length <= 20
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 12.0,
                              ),
                              child: Text(
                                '残り ${20 - model.newDisplayName.length} 文字です。',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFF39800),
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          child: Text('表示名を変更'),
                          color: Color(0xFFF39800),
                          textColor: Colors.white,
                          onPressed: model.isDisplayNameValid
                              ? () async {
                                  model.startLoading();
                                  try {
                                    await model.updateDisplayName(context);
                                    await showTextDialog(context, '表示名を変更しました');
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TopPage(),
                                      ),
                                    );
                                  } catch (e) {
                                    showTextDialog(context, e.toString());
                                    model.endLoading();
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }
}
