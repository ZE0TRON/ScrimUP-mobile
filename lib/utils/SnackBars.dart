import 'package:flutter/material.dart';

ErrorSnackBar(String errorMessage, double fontSize) {
  return new SnackBar(
    content: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: <Widget>[
          Icon(Icons.error),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          )
        ],
      ),
    ),
    backgroundColor: Colors.red,
  );
}

SucessSnackBar(String message, double fontSize) {
  return new SnackBar(
    content: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: <Widget>[
          Icon(Icons.error),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              message,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          )
        ],
      ),
    ),
    backgroundColor: Colors.green,
  );
}
