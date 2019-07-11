import 'package:ScrimUp/game/JoinCreateTeam.dart';
import 'package:flutter/material.dart';
import "../utils/session.dart";
import '../game/GameSelect.dart';
import "../utils/SnackBars.dart";
import '../utils/FirebaseAnalytics.dart';

class _VerificationState extends State<VerificationScreen> {
  Session session;
  double _buttonPaddingTop;
  double _formPaddingTop;
  double _notificationPadding;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _fontSize;
  String _errorMessage;
  _VerificationState(this.session);
  final verificationCodeController = new TextEditingController();
  void verify(context) {
    var verifyUrl = "/account/verify";

    session.post(verifyUrl,
        {"verificationCode": verificationCodeController.text}).then((response) {
      if (response["success"]) {
        session.notRegistered = false;
        sendAnalyticsEvent(session.analytics, "user_verified", {});
        session.post("/account/getAvatar", {}).then((response) {
          if (response["success"]) {
            session.avatar = response["avatar"];
          } else {
            session.avatar =
                "https://avatars.dicebear.com/v2/male/12312412165124.svg";
          }

          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (context) => JoinCreateTeamScreen(session)),
            (_) => false,
          );
        });
      } else {
        // print("error is ");
        _errorMessage = response["msg"];
        // print(_errorMessage);
        Scaffold.of(context)
            .showSnackBar(ErrorSnackBar(_errorMessage, _fontSize));
      }
    });
  }

  void sendVerifyMail(context) {
    var sendVerifyUrl = "/account/sendVerifyMail";
    session.post(sendVerifyUrl, {}).then((response) {
      _errorMessage = response["msg"];
      Scaffold.of(context)
          .showSnackBar(SucessSnackBar(_errorMessage, _fontSize));
    });
  }

  @override
  void dispose() {
    verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.020;
    _formPaddingTop = size.height * 0.011;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.071;
    _headerFontSize = size.width * 0.096;
    _fontSize = size.width * 0.057;
    return new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Verification"),
            ),
            body: Builder(builder: (BuildContext context) {
              return new Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: _containerPaddingSide),
                  child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index) {
                        switch (index) {
                          case 0:
                            return new Padding(
                                padding:
                                    EdgeInsets.only(top: _headerPaddingTop),
                                child: Image.asset(
                                    'assets/logo/logo_just_name.png'));
                          case 1:
                            return Padding(
                              padding:
                                  EdgeInsets.only(top: _buttonPaddingTop * 2),
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                decoration: new InputDecoration(
                                  labelText: "Verification Code",
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                controller: verificationCodeController,
                                maxLength: 6,
                                style: TextStyle(fontSize: _fontSize / 1.5),
                                keyboardType: TextInputType.number,
                                onSubmitted: (text) {
                                  if (verificationCodeController.text.length ==
                                      6) {
                                    verify(context);
                                  } else {
                                    Scaffold.of(context).showSnackBar(
                                        ErrorSnackBar(
                                            "Verification code should be 6 digits",
                                            _fontSize));
                                  }
                                },
                              ),
                            );
                          case 2:
                            return Padding(
                                padding: EdgeInsets.only(
                                  top: _buttonPaddingTop,
                                ),
                                child: Center(
                                    child: FlatButton(
                                  onPressed: () {
                                    if (verificationCodeController
                                            .text.length ==
                                        6) {
                                      verify(context);
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          ErrorSnackBar(
                                              "Verification code should be 6 digits",
                                              _fontSize));
                                    }
                                  },
                                  child: Text(
                                    "Verify",
                                    style: TextStyle(
                                        fontSize: _fontSize,
                                        color: Colors.orangeAccent),
                                  ),
                                )));
                          case 3:
                            return Padding(
                                padding: EdgeInsets.only(
                                    top: _buttonPaddingTop / 1.2),
                                child: Center(
                                    child: FlatButton(
                                  onPressed: () {
                                    sendVerifyMail(context);
                                  },
                                  child: FittedBox(
                                    child: Text("Send Verification Code Again",
                                        style: TextStyle(fontSize: _fontSize)),
                                    fit: BoxFit.scaleDown,
                                  ),
                                )));
                        }
                      }));
            })));
  }
}

class VerificationScreen extends StatefulWidget {
  Session session;
  VerificationScreen(this.session);
  _VerificationState createState() => _VerificationState(session);
}
