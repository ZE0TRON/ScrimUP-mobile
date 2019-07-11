import 'package:flutter/material.dart';
import './AvailabilityParse.dart';

class _TimeButtonState extends State<TimeButton> {
  String text;
  Availability availability;
  int index;
  double radius;
  double multiplier;
  var states = [0.0, 1.0];
  var colors = [
    Colors.black87,
    Colors.green,
  ];
  int _stateIndex;

  void _timeClicked() {
    int newIndex = (_stateIndex + 1) % 2;
    availability.setAvailability(this.index, states[newIndex]);
    setState(() {
      _stateIndex = newIndex;
    });
  }

  _TimeButtonState(
      this.text, this.availability, this.index, this.radius, this.multiplier);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var minWidth = size.width * 0.88;
    _stateIndex = availability.getAvailabilities()[index].round();
    var height = size.height * multiplier;
    var buttonPadding = size.height * 0.008;
    // print(availability.getAvailabilities());
    return new SizedBox(
      height: height,
      child: FlatButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(radius)),
        color: colors[_stateIndex],
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: size.width * 0.05),
          ),
        ),
        onPressed: () => _timeClicked(),
      ),
    );
  }
}

class TimeButton extends StatefulWidget {
  String text;
  double fontSize;
  Availability availability;
  int index;
  double multiplier;
  double radius;
  TimeButton(
      this.text, this.availability, this.index, this.radius, this.multiplier);
  @override
  _TimeButtonState createState() =>
      _TimeButtonState(text, availability, index, radius, multiplier);
}
