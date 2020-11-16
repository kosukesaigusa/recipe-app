import 'package:flutter/material.dart';

Widget customDoneButton(FocusNode _focusNode) {
  return GestureDetector(
    onTap: () {
      _focusNode.unfocus();
    },
    child: Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 8.0, right: 16.0),
      child: Text(
        '完了',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
