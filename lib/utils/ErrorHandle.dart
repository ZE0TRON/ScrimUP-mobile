import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SnackBars.dart';

void handleError(
    String error, BuildContext widgetContext, double buttonFontSize) {
  if (error == "Login first") {
    Navigator.pushNamedAndRemoveUntil(widgetContext, "/", (_) => false);
  } else {
    Scaffold.of(widgetContext)
        .showSnackBar(ErrorSnackBar(error, buttonFontSize));
  }
}

void handleSuccess(
    String msg, BuildContext widgetContext, double buttonFontSize) {
  Scaffold.of(widgetContext).showSnackBar(SucessSnackBar(msg, buttonFontSize));
}
