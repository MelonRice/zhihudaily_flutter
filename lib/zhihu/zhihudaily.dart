import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:zhihudaily/model/homePageModel.dart';
import 'package:zhihudaily/utils/WebUtils.dart';
import 'package:zhihudaily/widget/homeBanner.dart';
import 'package:zhihudaily/zhihu/storyItem.dart';

String selectedUrl = "http://daily.zhihu.com/story/9688113";

class ZhihuDailyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '知乎日报',
      color: Colors.grey,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SampleAppPage(),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => new _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  List<HomePageModel> homePageDataList = new List<HomePageModel>();
  List<TopStoriesModel> topBannerModel;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget buildItem(BuildContext context, int position) {
    Widget widget;

    HomePageModel item = homePageDataList[position];

    switch (item.itemType) {
      case HomePageModel.itemTypeBanner:
        widget = new HomeBanner(topBannerModel);
        break;
      case HomePageModel.itemTypeNormal:
        widget = getItem(context, position);
        break;
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("知乎日报"),
      ),
      body: new ListView.builder(
          itemCount: homePageDataList.length,
          itemBuilder: (BuildContext context, int position) {
            return buildItem(context, position);
          }),
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: new Text('Drawer Header'),
              decoration: new BoxDecoration(
                color: Colors.blue,
              ),
            ),
            new ListTile(
              title: new Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            new ListTile(
              title: new Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getItem(BuildContext context, int i) {
    return new Container(
        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: new StoryItem(
          detail: homePageDataList[i],
          onTap: () {
            WebUtils.startWebView(context, homePageDataList[i].id);
          },
        ));
  }


  loadData() async {
    String dataURL = "https://news-at.zhihu.com/api/4/news/latest";
    http.Response response = await http.get(dataURL);

    List banner = json.decode(response.body)["top_stories"];
    List storise = json.decode(response.body)["stories"];

    if (storise.isNotEmpty) {
      homePageDataList = storise.map((model) {
        return new HomePageModel.fromJson(model);
      }).toList();
    }

    if (banner.isNotEmpty) {
      topBannerModel = banner.map((model) {
        return new TopStoriesModel.fromJson(model);
      }).toList();

      HomePageModel top = new HomePageModel();
      top.setItemType(HomePageModel.itemTypeBanner);
      homePageDataList.insert(0, top);
    }

    setState(() {});
  }
}
