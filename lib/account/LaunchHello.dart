import 'package:ScrimUp/account/Launch.dart';
import 'package:flutter/material.dart';
import 'package:ScrimUp/utils/session.dart';

class LaunchHello extends StatelessWidget {
  Session session;

  LaunchHello(this.session);

  double borderCircleRadius = 5;
  double _buttonPaddingTop;
  double _formPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _fontSize;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.020;
    _formPaddingTop = size.height * 0.011;
    _containerPaddingSide = size.width * 0.10;
    _headerPaddingTop = size.height * 0.071;
    _headerFontSize = size.width * 0.096;
    _fontSize = size.width * 0.057;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Scrim UP"),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => Launch(session)), (_) {
              return false;
            }),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: _headerPaddingTop / 1.5,
              horizontal: _containerPaddingSide),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                0.01,
                0.3,
                1.0
              ],
                  colors: <Color>[
                Color.fromRGBO(255, 200, 70, 0.01),
                Color.fromRGBO(255, 200, 70, 0.2),
                Color.fromRGBO(255, 200, 70, 0.8)
              ])),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Hello",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _fontSize * 1.8),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: _headerPaddingTop * 1.5, bottom: _headerPaddingTop),
                child: Image(
                  image: AssetImage('assets/logo/logo_with_title.png'),
                  height: size.height * 0.4,
                ),
              ),
              FittedBox(
                child: FlatButton(
                  splashColor: Colors.transparent,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Let's get started.",
                      style: TextStyle(
                          fontSize: _fontSize * 1.3,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Launch(session)), (_) {
                      return false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
