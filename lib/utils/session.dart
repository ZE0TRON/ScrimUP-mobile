import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import "dart:io";

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/session.data');
}

Future<File> saveSession(Session session) async {
  final file = await _localFile;
  String cookie = session.getSession();
  return file.writeAsString(cookie);
}

class Session {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Map<String, String> headers = {};
  String serverUrl;
  String FCMToken;
  String avatar;
  FirebaseAnalytics analytics;
  bool notRegistered = true;
  FirebaseAnalyticsObserver observer;
  Session(this.serverUrl);

  Future<Map> get(String url) async {
    var getUrl = new Uri.https(serverUrl, url);
    // var getUrl = new Uri.http(serverUrl, url);
    http.Response response = await http.get(getUrl, headers: headers);
    await updateCookie(response);
    // print("This is what I get from server");
    // print(response.body);
    return json.decode(response.body);
    //return response;
  }

  String getSession() {
    if (headers.isNotEmpty) {
      return headers["cookie"];
    } else {
      return "NotFound";
    }
  }

  set cookie(String cookie) => headers["cookie"] = cookie;

  Future<Map> post(String url, dynamic data) async {
    var postUrl = new Uri.https(serverUrl, url);
    // var postUrl = new Uri.http(serverUrl, url);
    // print("I am sending");
    // print(data);
    http.Response response =
        await http.post(postUrl, body: data, headers: headers);
    await updateCookie(response);
    // print("Response is ");
    // print(response.body);
    return json.decode(response.body);

    //return response;
  }

  dynamic apiRequest(String url, Map jsonMap) async {
    // print("I am sending json req with");
    // print(jsonMap);
    var reqUrl = new Uri.https(serverUrl, url);
    // var reqUrl = new Uri.http(serverUrl, url);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(reqUrl);
    request.headers.set('content-type', 'application/json');
    request.headers.set('cookie', this.headers["cookie"]);
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    // todo - you should check the response.statusCode
    // print(json.decode(reply));
    return json.decode(reply);
  }

  Future<int> updateCookie(http.Response response) async {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      // print(rawCookie);
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    return 5;
  }

  Future<bool> setFCMToken(Session session) async {
    String FCMToken;
    _firebaseMessaging.getToken().then((token) async {
      if (token == null) {
        FCMToken = null;
      } else {
        FCMToken = token;
      }
      session.FCMToken = FCMToken;
    });
  }
}
