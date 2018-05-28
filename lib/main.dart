import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new NewsHomeWidget();
  }
}

class NewsHomeWidget extends State<MyApp> {
  var _fetching = true;
  var error = false;
  final url =
      "https://newsapi.org/v2/top-headlines?country=us&apiKey=";
  var _articles;

  _fetch() async {
    this.setState(() {
      _fetching = true;
    });
    print("Now fetching. . .");
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        this.setState(() {
          print("successfully retrieved news");
          _fetching = false;
          error = false;
          _articles = json.decode(response.body)["articles"];
        });
      } else {
        this.setState(() {
          print("network error code ${response.statusCode}");
          _fetching = false;
          error = true;
        });
      }
    }).catchError((e) {
      print("offline");
      this.setState(() {
        _fetching = false;
        error = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: "News",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Center(child: new Text("News")),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                _fetch();
              },
            )
          ],
        ),
        body: _fetching
            ? new Center(child: new CircularProgressIndicator())
            : error
                ? new Center(child: new Text("A network error has occured."))
                : new Center(
                    child: new NewsArticleList(_articles),
                  ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("App initialized");
    _fetch();
  }
}

class NewsArticleList extends StatelessWidget {
  final _articles;

  NewsArticleList(this._articles);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
        itemCount: _articles != null ? _articles.length : 0,
        shrinkWrap: true,
        itemBuilder: (context, row) {
          var _article = _articles[row];
          return new Column(
            children: <Widget>[
              new Container(
                padding: new EdgeInsets.all(8.0),
                child: new NewsArticleWidegt(_article),
              )
            ],
          );
        });
  }
}

class NewsArticleWidegt extends StatelessWidget {
  final _article;

  NewsArticleWidegt(this._article);

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      padding: new EdgeInsets.all(0.0),
      child: buildCol(context),
      onPressed: () {
        Navigator.push(context, new MaterialPageRoute(builder: (context) {
          return buildDetails(context);
        }));
      },
    );
  }

  Widget buildCol(BuildContext context) {
    // TODO: implement build
    return _article["urlToImage"] != null
        ? new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: _article["urlToImage"],
              ),
              new Container(
                height: 8.0,
              ),
              new Text(_article["title"],
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              new Divider()
            ],
          )
        : new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                height: 10.0,
              ),
              new Text(_article["title"],
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              new Divider()
            ],
          );
  }

  Widget buildDetails(BuildContext context) {
    return new MaterialApp(
      routes: {
        "/": (_)=> new WebviewScaffold(
          url: _article["url"],
          appBar: new AppBar(
            title: new Text(_article["title"]),
          ),
        )
      },
    );
  }
}
