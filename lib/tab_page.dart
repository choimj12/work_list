import 'package:flutter/material.dart';
import 'list_page.dart';
import 'worklist_page.dart';
import 'sharelist_page.dart';

class TabPage extends StatefulWidget {
  @override
  TabPageState createState() => TabPageState();
}

class TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "업무 일정 관리",
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: "일정 목록"),
              Tab(
                text: DateTime.now().month.toString() + " 월 " + DateTime.now().day.toString() + " 일 ",
              ),
              Tab(text: "공지 목록"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            WorkListPage(),
            ListPage(),
            ShareListPage()
          ],
        ),
      ),
    );
  }
}