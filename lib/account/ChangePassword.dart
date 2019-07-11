import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:core';
import '../utils/FirebaseAnalytics.dart';

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  TextEditingController passwordController = new TextEditingController();
  TextEditingController currentPasswordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();
  final FocusNode _currentPasswordFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _passwordConfirmFocus = new FocusNode();
  String passwordErrorText;
  String _errorMessage;
  Icon confirmIcon = Icon(Icons.lock);
  String passwordConfirmErrorText;
  Session session;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  double _buttonHeight;
  double isLeader = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    _currentPasswordFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    passwordConfirmController.dispose();
    currentPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _changePassword(context, currentPassword, newPassword) {
    var passwordChangeUrl = "/account/changePassword";
    session.post(passwordChangeUrl, {
      "currentPassword": currentPassword,
      "newPassword": newPassword
    }).then((response) async {
      if (response["success"]) {
        sendAnalyticsEvent(session.analytics, "change_password", {});
        Scaffold.of(context)
            .showSnackBar(SucessSnackBar("Password Changed", _buttonFontSize));
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(response["msg"], _buttonFontSize));
      }
    });
  }

  _emptyOne() {
    // print("c");
  }

  _PasswordChangeScreenState(this.session);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.02;
    _buttonHeight = size.height * 0.05;
    _containerPaddingSide = size.width * 0.12;
    _headerPaddingTop = size.height * 0.028;
    _headerFontSize = size.width * 0.096;
    _buttonFontSize = size.width * 0.06;
    _mediumFontSize = size.height * 0.030;
    return new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Reset Password"),
            ),
            body: Builder(builder: (BuildContext context) {
              return new Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: _containerPaddingSide),
                  child: Center(
                      child: Column(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: _headerPaddingTop * 3),
                        child: Image.asset('assets/logo/logo_just_name.png')),
                    Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop * 2),
                        child: TextField(
                          focusNode: _currentPasswordFocus,
                          decoration: new InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Current Password",
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                          ),
                          controller: currentPasswordController,
                          maxLines: 1,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (text) {
                            _currentPasswordFocus.unfocus();
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: _buttonFontSize / 1.5),
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop),
                        child: TextField(
                          focusNode: _passwordFocus,
                          decoration: new InputDecoration(
                            labelText: "New Password",
                            hintText:
                                "Password's length should be greater than 5 and must include a digit and letter",
                            hintStyle:
                                TextStyle(fontSize: _buttonFontSize / 3.5),
                            hintMaxLines: 1,
                            prefixIcon: Icon(Icons.lock),
                            errorText: passwordErrorText,

                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                          ),
                          controller: passwordController,
                          obscureText: true,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(fontSize: _buttonFontSize / 1.5),
                          onChanged: (text) {
                            RegExp exp =
                                new RegExp(r"(?=.{5,})(?=.*?[0-9]).*?[A-z].*");
                            Iterable<Match> matches = exp.allMatches(text);
                            setState(() {
                              if (matches.length == 0) {
                                passwordErrorText =
                                    "Doesn't match the criteria";
                              } else {
                                passwordErrorText = null;
                                if (text != passwordConfirmController.text) {
                                  passwordConfirmErrorText =
                                      "Passwords doesn't match";
                                  confirmIcon = Icon(FontAwesomeIcons.times,
                                      color: Colors.red);
                                } else {
                                  passwordConfirmErrorText = null;
                                  confirmIcon = Icon(FontAwesomeIcons.check,
                                      color: Colors.green);
                                }
                              }
                            });
                          },
                          onSubmitted: (text) {
                            _passwordFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_passwordConfirmFocus);
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop),
                        child: TextField(
                          focusNode: _passwordConfirmFocus,
                          decoration: new InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: confirmIcon,
                            errorText: passwordConfirmErrorText,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                          ),
                          controller: passwordConfirmController,
                          obscureText: true,
                          maxLines: 1,
                          style: TextStyle(fontSize: _buttonFontSize / 1.5),
                          onChanged: (text) {
                            setState(() {
                              if (text != passwordController.text) {
                                passwordConfirmErrorText =
                                    "Passwords doesn't match";
                                confirmIcon = Icon(FontAwesomeIcons.times,
                                    color: Colors.red);
                              } else {
                                passwordConfirmErrorText = null;
                                confirmIcon = Icon(FontAwesomeIcons.check,
                                    color: Colors.green);
                              }
                            });
                          },
                          onSubmitted: (text) {
                            if (currentPasswordController.text.length != 0 &&
                                passwordConfirmErrorText == null &&
                                passwordController.text.length > 0 &&
                                passwordConfirmController.text ==
                                    passwordController.text) {
                              _changePassword(
                                  context,
                                  currentPasswordController.text,
                                  passwordController.text);
                            } else if (currentPasswordController.text.length ==
                                0) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Current password can't be empty",
                                  _buttonFontSize));
                            } else if (passwordErrorText != null) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Password doesn't match criteria",
                                  _buttonFontSize));
                            } else if (passwordController.text.length == 0) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Password can't be empty", _buttonFontSize));
                            } else if (passwordConfirmController.text !=
                                passwordController.text) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Passwords doesn't match", _buttonFontSize));
                            }
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop),
                        child: FlatButton(
                            child: Text(
                              "Change Password",
                              style: TextStyle(
                                  fontSize: _buttonFontSize,
                                  color: Colors.orangeAccent),
                            ),
                            onPressed: () {
                              if (currentPasswordController.text.length != 0 &&
                                  passwordConfirmErrorText == null &&
                                  passwordController.text.length > 0 &&
                                  passwordConfirmController.text ==
                                      passwordController.text) {
                                _changePassword(
                                    context,
                                    currentPasswordController.text,
                                    passwordController.text);
                              } else if (currentPasswordController
                                      .text.length ==
                                  0) {
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    "Current password can't be empty",
                                    _buttonFontSize));
                              } else if (passwordErrorText != null) {
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    "Password doesn't match criteria",
                                    _buttonFontSize));
                              } else if (passwordController.text.length == 0) {
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    "Password can't be empty",
                                    _buttonFontSize));
                              } else if (passwordConfirmController.text !=
                                  passwordController.text) {
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    "Passwords doesn't match",
                                    _buttonFontSize));
                              }
                            })),
                  ])));
            })));
  }
}

class PasswordChangeScreen extends StatefulWidget {
  Session session;
  PasswordChangeScreen(this.session);
  _PasswordChangeScreenState createState() =>
      _PasswordChangeScreenState(session);
}
