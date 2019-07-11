import 'package:flutter/widgets.dart';

class LinkState with ChangeNotifier {
  String _link = "";
  String _token = "";
  void set link(String link) {
    _link = link;
    notifyListeners();
  }

  void set token(String token) {
    _token = token;
    notifyListeners();
  }

  String get token => _token;
  String get link => _link;
}
