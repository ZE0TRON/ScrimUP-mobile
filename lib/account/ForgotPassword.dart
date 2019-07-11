import 'package:flutter/material.dart';
import "../utils/session.dart";
import "../utils/SnackBars.dart";
import './ResetPassword.dart';
import 'package:email_validator/email_validator.dart';
import '../utils/FirebaseAnalytics.dart';

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  double _buttonPaddingTop;
  Session session;
  double _containerPaddingSide;
  final TextEditingController emailController = new TextEditingController();
  _ForgotPasswordScreenState(this.session);
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _mediumFontSize;
  String _errorMessage;
  String mailErrorText;
  double _buttonHeight;
  bool isEmailEdited = false;
  void resetPassword(context) {
    var forgotPasswordUrl = "/account/forgotPassword";
    session.post(forgotPasswordUrl, {"email": emailController.text}).then(
        (response) async {
      if (response["success"]) {
        sendAnalyticsEvent(session.analytics, "forgot_password", {});
        Scaffold.of(context)
            .showSnackBar(SucessSnackBar("Recover code sent", _buttonFontSize));
        await Future.delayed(Duration(seconds: 2));
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(session, emailController.text),
            ));
      } else {
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(response["msg"], _buttonFontSize));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
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
              title: Text("Forgot Password"),
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
                          decoration: new InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              borderSide: new BorderSide(),
                            ),
                            errorText: mailErrorText,

                            //fillColor: Colors.green
                          ),
                          controller: emailController,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (text) {
                            isEmailEdited = true;
                            setState(() {
                              if (!EmailValidator.validate(text)) {
                                mailErrorText = "Please enter a valid email";

                                // print("Please enter a valid email");
                              } else {
                                mailErrorText = null;
                              }
                            });
                          },
                          onSubmitted: (text) {
                            if (emailController.text.length > 0 &&
                                mailErrorText == null) {
                              resetPassword(context);
                            } else if (emailController.text.length == 0) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Email can't be empty", _buttonFontSize));
                            }
                          },
                          style: TextStyle(fontSize: _buttonFontSize / 1.5),
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: _buttonPaddingTop),
                        child: FlatButton(
                          child: Text(
                            "Send Recover Code",
                            style: TextStyle(
                                fontSize: _buttonFontSize, color: Colors.white),
                          ),
                          onPressed: () {
                            if (emailController.text.length > 0 &&
                                mailErrorText == null) {
                              resetPassword(context);
                            } else if (emailController.text.length == 0) {
                              Scaffold.of(context).showSnackBar(ErrorSnackBar(
                                  "Email can't be empty", _buttonFontSize));
                            }
                          },
                        )),
                  ])));
            })));
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  Session session;
  ForgotPasswordScreen(this.session);
  _ForgotPasswordScreenState createState() =>
      _ForgotPasswordScreenState(session);
}
