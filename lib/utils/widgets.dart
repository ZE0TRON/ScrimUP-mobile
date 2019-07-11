import 'package:flutter/material.dart';
import 'dart:math';

class NewItem {
  bool isExpanded;
  final Widget header;
  final Widget body;
  final Icon iconpic;
  NewItem(this.isExpanded, this.header, this.body, this.iconpic);
}

int randomInt() {
  Random random = Random();
  return random.nextInt(512512);
}

class MyBullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 20.0,
      width: 20.0,
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

Future<bool> areYouSureDialog(String sureText, BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure ?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(sureText),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          FlatButton(
            child: Text(
              'No',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      );
    },
  );
}

class _MemberSelectWindow extends State<MemberSelectWindow> {
  String member;
  @override
  void initState() {
    super.initState();
    member = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.values);
    return DropdownButton(
      value: widget.initialValue,
      items: widget.values.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      onChanged: (value) {
        print("I am changing");
        setState(() {
          member = value;
        });
        widget.onValueChange(value);
      },
    );
  }
}

class MemberSelectWindow extends StatefulWidget {
  final String initialValue;
  final List<String> values;
  final void Function(String) onValueChange;
  MemberSelectWindow({this.onValueChange, this.initialValue, this.values});

  @override
  _MemberSelectWindow createState() => _MemberSelectWindow();
}

class Spinner extends StatefulWidget {
  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Image.asset(
        'assets/icon/android_icon.png',
        height: 80,
        width: 80,
      ),
      builder: (BuildContext context, Widget child) {
        return Transform.rotate(
          angle: _controller.value * 110.0 * pi,
          child: child,
        );
      },
    );
  }
}
