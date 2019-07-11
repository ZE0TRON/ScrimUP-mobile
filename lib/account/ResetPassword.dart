import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/FirebaseAnalytics.dart';

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String email;
  double _buttonPaddingTop;
  double _containerPaddingSide;
  final TextEditingController codeController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController passwordConfirmController =
      new TextEditingController();
  final FocusNode _recoverCodeFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _passwordConfirmFocus = new FocusNode();

  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  String passwordErrorText;
  String _errorMessage;
  Icon confirmIcon = Icon(Icons.lock);
  String passwordConfirmErrorText;
  double _buttonHeight;
  Session session;

  void resetPassword(context) {
    var newPassword = passwordController.text;
    var confirmPassword = passwordConfirmController.text;
    if ((newPassword != confirmPassword) || (confirmPassword.length == 0)) {
      Scaffold.of(context).showSnackBar(
          ErrorSnackBar("Passwords Don't Match", _buttonFontSize));
    } else {
      var passwordChangeUrl = "/account/resetPassword";
      session.post(passwordChangeUrl, {
        "email": email,
        "recoverKey": codeController.text,
        "newPassword": passwordController.text
      }).then((response) {
        if (response["success"]) {
          sendAnalyticsEvent(session.analytics, "reset_password", {});
          Navigator.pop(context);
          Navigator.pop(context);
          Scaffold.of(context)
              .showSnackBar(SucessSnackBar(response["msg"], _buttonFontSize));
        } else {
          Scaffold.of(context)
              .showSnackBar(ErrorSnackBar(response["msg"], _buttonFontSize));
        }
      });
    }
  }

  _ResetPasswordScreenState(this.session, this.email);
  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    _recoverCodeFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    super.dispose();
  }

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
                          focusNode: _recoverCodeFocus,
                          decoration: new InputDecoration(
                            labelText: "Recover Code",
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                          ),
                          controller: codeController,
                          maxLength: 6,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (text) {
                            _recoverCodeFocus.unfocus();
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          keyboardType: TextInputType.number,
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
                            if (codeController.text.length == 6 &&
                                passwordConfirmErrorText == null &&
                                passwordController.text.length > 0 &&
                                passwordConfirmController.text ==
                                    passwordController.text) {
                              resetPassword(context);
                            } else if (codeController.text.length != 6) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Recover code should be 6 digits",
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
                              "Reset Password",
                              style: TextStyle(
                                  fontSize: _buttonFontSize,
                                  color: Colors.blue),
                            ),
                            onPressed: () {
                              if (codeController.text.length == 6 &&
                                  passwordConfirmErrorText == null &&
                                  passwordController.text.length > 0 &&
                                  passwordConfirmController.text ==
                                      passwordController.text) {
                                resetPassword(context);
                              } else if (codeController.text.length != 6) {
                                Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                    "Recover code should be 6 digits",
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

class ResetPasswordScreen extends StatefulWidget {
  String email;
  Session session;
  ResetPasswordScreen(this.session, this.email);
  _ResetPasswordScreenState createState() =>
      _ResetPasswordScreenState(session, email);
}
