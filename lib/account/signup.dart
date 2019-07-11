import 'package:flutter/material.dart';
import "../utils/session.dart";
import 'package:email_validator/email_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import "dart:io";
import "./verification.dart";
import './login.dart';
import "../utils/SnackBars.dart";
import '../utils/FirebaseAnalytics.dart';

class _SignupScreenState extends State<SignupScreen> {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  double emailOkey = 0;
  bool isPasswordValid = false;
  bool isEmailEdited = false;
  bool isTermsAccepted = false;
  bool isPrivacyPAccepted = false;
  double isError = 0.0;
  String _errorMessage = "";
  double borderCircleRadius = 5;
  double _buttonPaddingTop;
  double _formPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  String mailErrorText;
  double _fontSize;
  Icon confirmIcon = Icon(Icons.lock);
  String passwordErrorText;
  String passwordConfirmErrorText;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();

  void signup(context) {
    var signupUrl = "/account/signup";

    session.post(signupUrl, {
      "email": mailController.text,
      "password": passwordController.text,
      "FCMToken": session.FCMToken
    }).then((response) async {
      if (response["success"] || response["msg"] == "Not verified") {
        saveSession(session);
        sendAnalyticsEvent(session.analytics, "email_signup", {});
        Scaffold.of(context).showSnackBar(
            SucessSnackBar("Verification Code Sent To Your Email", _fontSize));
        await Future.delayed(Duration(seconds: 3));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(session),
            ), (_) {
          return false;
        });
      } else {
        _errorMessage = response["msg"];
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(_errorMessage, _fontSize));
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    mailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _passwordConfirmFocus.dispose();
    super.dispose();
  }

  Session session;
  String FCMToken;
  _SignupScreenState(this.session, this.FCMToken);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.020;
    _formPaddingTop = size.height * 0.011;
    _containerPaddingSide = size.width * 0.10;
    _headerPaddingTop = size.height * 0.071;
    _headerFontSize = size.width * 0.096;
    _fontSize = size.width * 0.057;
    return new GestureDetector(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Scrim UP"),
            ),
            body: Center(child: Builder(builder: (BuildContext context) {
              return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: _containerPaddingSide),
                  child: ListView(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: _headerPaddingTop * 1.4),
                        child: Image.asset('assets/logo/logo_just_name.png')),
                    Padding(
                        padding: EdgeInsets.only(top: _formPaddingTop * 2),
                        child: Form(
                            child: Column(children: <Widget>[
                          TextField(
                            focusNode: _emailFocus,
                            decoration: new InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: "Email",
                              errorText: mailErrorText,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(
                                    borderCircleRadius),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            textInputAction: TextInputAction.next,
                            controller: mailController,
                            maxLines: 1,
                            onSubmitted: (text) {
                              if (mailErrorText == null) {
                                _emailFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              }
                            },
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (text) {
                              if (!EmailValidator.validate(text)) {
                                setState(() {
                                  mailErrorText = "Please enter a valid email";
                                });
                                // print("Please enter a valid email");
                              } else {
                                setState(() {
                                  mailErrorText = null;
                                });
                              }
                            },
                            style: TextStyle(fontSize: _fontSize / 1.5),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: _buttonPaddingTop),
                              child: TextField(
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.next,
                                decoration: new InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: Icon(Icons.lock),
                                  errorText: passwordErrorText,
                                  hintText:
                                      "Password's length should be greater than 5 and must include a digit and letter",
                                  hintStyle:
                                      TextStyle(fontSize: _fontSize / 3.5),
                                  hintMaxLines: 1,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(
                                        borderCircleRadius),
                                    borderSide: new BorderSide(),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: passwordController,
                                maxLines: 1,
                                onSubmitted: (text) {
                                  if (passwordErrorText == null) {
                                    _passwordFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_passwordConfirmFocus);
                                  }
                                },
                                onChanged: (text) {
                                  RegExp exp = new RegExp(
                                      r"(?=.{5,})(?=.*?[0-9]).*?[A-z].*");
                                  Iterable<Match> matches =
                                      exp.allMatches(text);
                                  setState(() {
                                    if (matches.length == 0) {
                                      passwordErrorText =
                                          "Doesn't match the criteria";
                                      isPasswordValid = false;
                                    } else {
                                      passwordErrorText = null;
                                      isPasswordValid = true;
                                    }
                                    if (text !=
                                        passwordConfirmController.text) {
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
                                obscureText: true,
                                style: TextStyle(fontSize: _fontSize / 1.5),
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: _buttonPaddingTop),
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              focusNode: _passwordConfirmFocus,
                              decoration: new InputDecoration(
                                prefixIcon: confirmIcon,
                                labelText: "Confirm Password",
                                errorText: passwordConfirmErrorText,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(
                                      borderCircleRadius),
                                  borderSide: new BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              controller: passwordConfirmController,
                              maxLines: 1,
                              onSubmitted: (text) {
                                if (mailController.text.length > 0 &&
                                    mailErrorText == null &&
                                    passwordController.text.length > 0 &&
                                    passwordController.text ==
                                        passwordConfirmController.text &&
                                    isTermsAccepted &&
                                    isPrivacyPAccepted &&
                                    isPasswordValid) {
                                  signup(context);
                                }
                              },
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
                              obscureText: true,
                              style: TextStyle(fontSize: _fontSize / 1.5),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: _buttonPaddingTop),
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  activeColor: Theme.of(context).accentColor,
                                  value: isTermsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      isTermsAccepted = value;
                                    });
                                  },
                                ),
                                Text(
                                  "I have read and accept the ",
                                  style: TextStyle(fontSize: _fontSize / 2),
                                ),
                                FlatButton(
                                  splashColor: Colors.transparent,
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    "terms and conditions.",
                                    style: TextStyle(
                                        fontSize: _fontSize / 2,
                                        decoration: TextDecoration.underline),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return WebviewScaffold(
                                        url: "http://scrimupapp.com/EULA.html",
                                        appBar: AppBar(
                                          title: Text("Terms and Conditions"),
                                        ),
                                        hidden: true,
                                        withLocalStorage: true,
                                      );
                                    }));
                                  },
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                activeColor: Theme.of(context).accentColor,
                                value: isPrivacyPAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    isPrivacyPAccepted = value;
                                  });
                                },
                              ),
                              Text(
                                "I have read and accept the",
                                style: TextStyle(fontSize: _fontSize / 2),
                              ),
                              FlatButton(
                                splashColor: Colors.transparent,
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  "privacy policy.",
                                  style: TextStyle(
                                      fontSize: _fontSize / 2,
                                      decoration: TextDecoration.underline),
                                ),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return WebviewScaffold(
                                      url: "http://scrimupapp.com/Privacy.html",
                                      //url: "https://google.com",
                                      appBar: AppBar(
                                        title: Text("Privacy Policy"),
                                      ),
                                      withLocalStorage: true,
                                      hidden: true,
                                    );
                                  }));
                                },
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: _buttonPaddingTop * 1.5),
                            child: FlatButton(
                                child: Text(
                                  "Signup",
                                  style: TextStyle(
                                      fontSize: _fontSize,
                                      color: Colors.orangeAccent),
                                ),
                                onPressed: () {
                                  // print("I am here");
                                  // print(logsignb);
                                  if (mailController.text.length > 0 &&
                                      mailErrorText == null &&
                                      passwordController.text.length > 0 &&
                                      passwordController.text ==
                                          passwordConfirmController.text &&
                                      isTermsAccepted &&
                                      isPrivacyPAccepted &&
                                      isPasswordValid) {
                                    signup(context);
                                  } else if (mailController.text.length == 0) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "Email can't be empty", _fontSize));
                                  } else if (mailErrorText != null) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "Email is invalid", _fontSize));
                                  } else if (passwordController.text.length ==
                                      0) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar("Password can't be empty",
                                            _fontSize));
                                  } else if (!isPasswordValid) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "Password doesn't match the criteria",
                                            _fontSize));
                                    sendAnalyticsEvent(session.analytics,
                                        "invalid_password_criteria", {});
                                  } else if (passwordController.text !=
                                      passwordConfirmController.text) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar("Passwords doesn't match",
                                            _fontSize));
                                  } else if (!isTermsAccepted) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "You must accept terms and conditions",
                                            _fontSize));
                                  } else if (!isPrivacyPAccepted) {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "You must accept privacy policy",
                                            _fontSize));
                                  }
                                }),
                          ),
                          Center(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: FlatButton(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Already have an account ? Login",
                                      style: TextStyle(
                                          fontSize: _fontSize,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              new LoginScreen(session),
                                        ), (_) {
                                      return false;
                                    });
                                  }),
                            ),
                          ),
                        ]))),
                    Padding(
                      padding: EdgeInsets.only(top: _buttonPaddingTop),
                      child: FlatButton(
                          padding: EdgeInsets.only(
                            left: _containerPaddingSide / 2,
                            right: _containerPaddingSide / 2,
                          ),
                          onPressed: () {
                            widget.session.notRegistered = true;
                            // TODO: check local db for games if not game go to game select
                          },
                          child: Text("Continue without Register",
                              style: TextStyle(fontSize: _fontSize / 1.2))),
                    )
                  ]));
            }))),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        });
  }
}

class SignupScreen extends StatefulWidget {
  Session session;
  String FCMToken;
  SignupScreen(this.session, this.FCMToken);
  _SignupScreenState createState() => _SignupScreenState(session, FCMToken);
}
