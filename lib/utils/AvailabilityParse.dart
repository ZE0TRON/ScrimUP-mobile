class DayTime {
  double _difference;
  var weekdays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];
  DayTime(double difference) {
    this._difference = -1 * (difference);
    // print("Difference is ");
    // print(this._difference); // This litter trick should convert local time to utc time
  }
  List<dynamic> getTimes(String day, List<int> intHours) {
    int iHour1 = intHours[0];
    int iHour2 = intHours[1];
    // print("getTimes Debug");
    //  print("Ihour1 before "+iHour1.toString());
    // print("Ihour2 before "+iHour2.toString());
    // print("Day before "+day);
    double nHour2 = (iHour2 + _difference); // TODO:change the difference as int
    double nHour1 = (iHour1 + _difference);

    // print("Nhour 1 :"+nHour1.toString());
    // print("Nhour 2 :"+nHour2.toString());
    // print("Day:"+day);
    if (nHour2 > 23) {
      nHour2 -= 24;
    }
    if (nHour1 > 23) {
      nHour1 -= 24;
      int nDayIndex = (weekdays.indexOf(day) + 1) % 7;
      day = weekdays[nDayIndex];
    }
    if (nHour1 < 0) {
      nHour1 += 24;
      int nDayIndex = (weekdays.indexOf(day) - 1) % 7;
      day = weekdays[nDayIndex];
    }
    // print("Nhour 1 later :"+nHour1.toString());
    // print("Nhour 2 later :"+nHour2.toString());
    // print("Day later :"+day);
    if (nHour2 < 0) {
      nHour2 += 24;
    }
    var hours = [];
    // print("nHour2 is ");
    // print(nHour2);
    bool flag;
    // print("Ihour1 later "+nHour1.toString());
    while (nHour1 != nHour2) {
      flag = false;
      if (nHour1 > 23) {
        flag = true;
        int nDayIndex = (weekdays.indexOf(day) + 1) % 7;
        day = weekdays[nDayIndex];
        nHour1 %= 24;
      }
      var dayHour = [day, nHour1];
      hours.add(dayHour);
      if (!flag) {
        nHour1 = (nHour1 + 1);
      }
    }
    /*String nHour = (nHour1.toInt()).toString()+":"+
    (nHour1-nHour1.toInt()).toStringAsFixed(2).substring(2)+
    amPm1.toUpperCase()+"-"+((nHour2.toInt()).toString()+":"+
    (nHour2-nHour2.toInt()).toStringAsFixed(2).substring(2))+
    amPm2.toUpperCase();
    */

    // print("Ihour2 later "+nHour2.toString());
    // print("Day later "+day);
    return hours;
  }

  List<String> singleHourParse(String day, String hour) {
    int iHour1 = int.parse(hour.substring(1));
    double nHour1 = (iHour1 - _difference);
    if (nHour1 > 23) {
      nHour1 -= 24;
      int nDayIndex = (weekdays.indexOf(day) + 1) % 7;
      day = weekdays[nDayIndex];
    }
    if (nHour1 < 0) {
      nHour1 += 24;
      int nDayIndex = (weekdays.indexOf(day) - 1) % 7;
      day = weekdays[nDayIndex];
    }
    List<String> hours = new List<String>();
    hours.add(day);
    hours.add(nHour1.toInt().toString());

    return hours;
  }

  List<String> parseTime(String day, String hour) {
    int iHour1 = int.parse(hour.substring(1));
    int iHour2 = (iHour1 + 1) % 24;
    // print("Parse time debug");
    // print("Ihour1 before "+iHour1.toString());
    // print("Ihour2 before "+iHour2.toString());
    // print("Day before "+day);
    double nHour1 = (iHour1 - _difference);
    double nHour2 = (iHour2 - _difference);
    bool flag = false;
    if (nHour2 > 23) {
      nHour2 -= 24;
      int nDayIndex = (weekdays.indexOf(day) + 1) % 7;
      day = weekdays[nDayIndex];
      flag = true;
    }
    if (nHour1 > 23) {
      nHour1 -= 24;
      if (!flag) {
        int nDayIndex = (weekdays.indexOf(day) + 1) % 7;
        day = weekdays[nDayIndex];
      }
      flag = true;
    }
    if (nHour1 < 0) {
      nHour1 += 24;
      if (!flag) {
        int nDayIndex = (weekdays.indexOf(day) - 1) % 7;
        day = weekdays[nDayIndex];
      }
      flag = true;
    }
    if (nHour2 < 0) {
      nHour2 += 24;
      if (!flag) {
        int nDayIndex = (weekdays.indexOf(day) - 1) % 7;
        day = weekdays[nDayIndex];
      }
      flag = true;
    }
    String amPm1 = "";
    String amPm2 = "";
    amPm1 = nHour1 < 12 ? "am" : "pm";
    nHour1 %= 12;
    amPm2 = nHour2 < 12 ? "am" : "pm";
    nHour2 %= 12;
    List<String> hours = new List<String>();
    String nHour = (nHour1.toInt()).toString() +
        ":" +
        (nHour1 - nHour1.toInt()).toStringAsFixed(2).substring(2) +
        amPm1.toUpperCase() +
        "-" +
        ((nHour2.toInt()).toString() +
            ":" +
            (nHour2 - nHour2.toInt()).toStringAsFixed(2).substring(2)) +
        amPm2.toUpperCase();
    hours.add(day);
    hours.add(nHour);
    // print("Ihour1 later "+nHour1.toString());
    // print("Ihour2 later "+nHour2.toString());
    // print("Day later "+day);
    return hours;
  }
}

class Availability {
  var _availabilities = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  void setAvailability(int index, double value) {
    _availabilities[index] = value;
  }

  List<double> getAvailabilities() {
    return _availabilities;
  }

  double getAvailability(int index) {
    return _availabilities[index];
  }

  void parseAvailability(var times) {
    _availabilities[0] = ((times[0] + times[1]) / 2).floor() + 0.0;
    _availabilities[1] =
        ((times[2] + times[3] + times[4] + times[5]) / 4).floor() + 0.0;
    _availabilities[2] =
        ((times[6] + times[7] + times[8] + times[9] + times[10]) / 5).floor() +
            0.0;
    _availabilities[3] = ((times[11] + times[12]) / 2).floor() + 0.0;
    _availabilities[4] = ((times[13] + times[14]) / 2).floor() + 0.0;
    _availabilities[5] = ((times[15] + times[16]) / 2).floor() + 0.0;
    _availabilities[6] = ((times[17] + times[18]) / 2).floor() + 0.0;
    _availabilities[7] = ((times[19] + times[20]) / 2).floor() + 0.0;
    _availabilities[8] = ((times[21] + times[23]) / 2).floor() + 0.0;
  }
}

class GeneralAvailability extends Availability {
  var _generalAvailabilities = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  @override
  void setAvailability(int index, double value) {
    _generalAvailabilities[index] = value;
  }

  @override
  List<double> getAvailabilities() {
    return _generalAvailabilities;
  }

  double getAvailability(int index) {
    return _generalAvailabilities[index];
  }

  void parseAvailability(var times) {
    _generalAvailabilities[0] = ((times[0] + times[1] / 2)).floor() + 0.0;
    _generalAvailabilities[1] =
        ((times[2] + times[3] + times[4] + times[5] + times[6] + times[7]) / 6)
                .floor() +
            0.0;
    _generalAvailabilities[2] =
        ((times[8] + times[9] + times[10] + times[11]) / 4).floor() + 0.0;
    _generalAvailabilities[3] = ((times[12] +
                    times[13] +
                    times[14] +
                    times[15] +
                    times[16] +
                    times[17]) /
                6)
            .floor() +
        0.0;
    _generalAvailabilities[4] = ((times[18] + times[19]) / 2).floor() + 0.0;
    _generalAvailabilities[5] =
        ((times[20] + times[21] + times[22] + times[23]) / 4).floor() + 0.0;
  }

  void singleDayParse(var times) {
    _generalAvailabilities[0] = ((times[0] + times[1] / 2)).floor() + 0.0;
    _generalAvailabilities[1] =
        ((times[2] + times[3] + times[4] + times[5] + times[6] + times[7]) / 6)
                .floor() +
            0.0;
    _generalAvailabilities[2] =
        ((times[8] + times[9] + times[10] + times[11]) / 4).floor() + 0.0;
    _generalAvailabilities[3] = ((times[12] +
                    times[13] +
                    times[14] +
                    times[15] +
                    times[16] +
                    times[17]) /
                6)
            .floor() +
        0.0;
    _generalAvailabilities[4] = ((times[18] + times[19]) / 2).floor() + 0.0;
    _generalAvailabilities[5] =
        ((times[20] + times[21] + times[22] + times[23]) / 4).floor() + 0.0;
  }
}
