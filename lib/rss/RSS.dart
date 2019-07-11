import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webfeed/webfeed.dart';

class RSSPage extends StatefulWidget {
  @override
  _RSSPageState createState() => _RSSPageState();
}

class _RSSPageState extends State<RSSPage> {
  final client = http.Client();
  bool isLoaded = false;
  var titles = [];
  var links = [];
  var dates = [];
  double _buttonPaddingTop;
  double _containerPaddingSide;
  double _headerPaddingTop;
  double _headerFontSize;
  double _buttonFontSize;
  double _notificationPadding;
  double _mediumFontSize;

  Future<String> getRSS() async {
    var response = await client.get("https://esportsinsider.com/feed/");
    return response.body;
  }

  void parseRSS() async {
    var tempTitles = [];
    var tempLinks = [];
    var tempDates = [];
    var body = await getRSS();
    var channel = RssFeed.parse(body);
    channel.items.forEach((item) {
      tempTitles.add(item.title);
      tempLinks.add(item.link);
      tempDates.add(item.pubDate.substring(0, item.pubDate.length - 6));
    });
    setState(() {
      isLoaded = true;
      titles = tempTitles;
      links = tempLinks;
      dates = tempDates;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buttonPaddingTop = size.height * 0.006;
    _containerPaddingSide = size.width * 0.12;
    _notificationPadding = size.height * 0.10;
    _headerPaddingTop = size.height * 0.038;
    _headerFontSize = size.height * 0.044;
    _buttonFontSize = size.height * 0.020;
    _mediumFontSize = size.height * 0.030;
    if (isLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Esport News"),
        ),
        body: Container(
            child: ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: _containerPaddingSide / 8,
              vertical: _containerPaddingSide / 8),
          itemCount: titles.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebviewScaffold(
                      url: links[index],
                      appBar: AppBar(
                        title: Text(titles[index]),
                      ),
                      withLocalStorage: true,
                    );
                  })),
              child: Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          titles[index],
                          style: TextStyle(fontSize: _headerFontSize / 1.75),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          dates[index],
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: _mediumFontSize / 2,
                              color: Colors.orange),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )),
      );
    } else {
      parseRSS();
      return Scaffold(
        appBar: AppBar(
          title: Text("Esport News"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
