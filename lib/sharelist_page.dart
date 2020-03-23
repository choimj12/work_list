import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ShareListPage extends StatefulWidget {
  @override
  ShareListPageState createState() => ShareListPageState ();
}

class ShareListPageState extends State<ShareListPage> {
  CalendarController _calendarController;

  FirebaseProvider fp;
  Firestore _db = Firestore.instance;

  DateTime nowDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<String, bool> _flag =  {"me": true, "other" : false };

  String key = "me";

  int i = 0;

  List receiveusername = List();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();

  }

  @override
  Widget build(BuildContext context){

    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              availableCalendarFormats: const{
                CalendarFormat.week: 'week'
              },
              onDaySelected: (date, events) {
                setState(() {
                  nowDate = DateTime(date.year, date.month, date.day);
                });

              },
              locale: 'ko_KO',
              initialCalendarFormat: CalendarFormat.week,
              calendarController: _calendarController,
              calendarStyle: CalendarStyle(
                  todayColor: Colors.deepPurple,
                  selectedColor: Colors.amberAccent,
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white
                  )
              ),
            ),

            Divider(),

            Row(
              children: <Widget>[
               Expanded(
                 flex: 2,
                 child:  Text(
                   "공유 목록",
                   style: TextStyle(
                       fontSize: 27,
                       color: Colors.deepPurple
                   ),
                 ),
               ),

                SafeArea(
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        textColor: _flag["me"] == false ? Colors.white : Colors.black,
                        color: _flag["me"] == false ? Colors.deepPurple : Colors.amberAccent,
                        child: Text("Me"),
                        shape: CircleBorder(),
                        onPressed: () {
                          setState(() {
                            _flag["me"] = true;
                            _flag["other"] = false;
                            key = "me";
                          });
                        },
                      ),

                      RaisedButton(
                        textColor: _flag["other"] == false ? Colors.white : Colors.black,
                        color: _flag["other"] == false ? Colors.deepPurple : Colors.amberAccent,
                        child: Text("Other"),
                        shape: CircleBorder(),
                        onPressed: () {
                          setState(() {
                            _flag["me"] = false;
                            _flag["other"] = true;
                            key = "other";
                          });
                        },
                      ),
                    ],
                  ),
                )

              ],
            ),



            Padding(
              padding: EdgeInsets.only(top: 10),
            ),

            Divider(
              height: 1.0,
              color: Colors.deepPurple,
              thickness: 2,
              endIndent: 200,
            ),

            StreamBuilder(
                stream: _db.collection("user").document(fp.getUser().email).collection("share").where("flag", isEqualTo: key).where("writeDate", isEqualTo: nowDate.toString()).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return new Center(child: new CircularProgressIndicator());
                  }

                  var noticeList = snapshot.data.documents ?? [];

                  if(noticeList.length == 0) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 130),
                      child: Text(
                        "목록이 없습니다.",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    );
                  }
                  else
                    return Expanded(
                      child: ListView.builder(
                        itemCount: noticeList.length,
                        itemBuilder: (context, index) {

                          return Card(
                            child: ListTile(
                                leading: CircleAvatar(
                                  radius: 23,
                                  child: Text(
                                    //작성자
                                    noticeList.elementAt(index).data["writerName"],
                                    style: TextStyle(
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                                title: Text(
                                  //제목
                                  noticeList.elementAt(index).data["title"],
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                                trailing: key == "me" ? Text(
                                  noticeList.elementAt(index).data["count"].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ) : Icon(
                                    Icons.done,
                                    color: noticeList.elementAt(index).data["confirm"] == true ? Colors.green : Colors.red
                                ),
                                onTap: key == "me" ? () {
                                  receiveusername = [];
                                  shareListDetail2(noticeList.elementAt(index));
                                } :() {
                                  _db.collection("user").document(fp.getUser().email).collection("share").document(noticeList.elementAt(index).documentID).updateData({
                                    "confirm": true
                                  });

                                  if(noticeList.elementAt(index).data["confirm"] == false){
                                    _db.collection("user").document(noticeList.elementAt(index).data["name"]).collection("share").document(noticeList.elementAt(index).documentID).get().then((DocumentSnapshot doc){
                                      setState(() {
                                        i = doc["count"];
                                        i = doc["count"] - 1;
                                      });
                                      _db.collection("user").document(noticeList.elementAt(index).data["name"]).collection("share").document(noticeList.elementAt(index).documentID).updateData({
                                        "count" : i
                                      });
                                    });
                                    print(i);
                                  }

                                  shareListDetail(noticeList.elementAt(index));
                                }
                            ),
                          );
                        },
                      ),
                    );
                }
            )
          ],
        ),
      ),
    );
  }

  void shareListDetail(DocumentSnapshot doc){

    String title = doc["title"];
    String writername = doc["writerName"];
    String date = doc["writeDate"];
    String detail = doc["detail"];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                ),
                title: Text(
                  "상세보기",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Container(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "제목 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "작성자 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                writername,
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "공유 일자 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                date.toString().substring(0, 10),
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "상세 내용 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                detail,
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),
                      ]
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          "확인",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ],
                  )
                ],
              );
            },
          );
        }
    );
  }

  void shareListDetail2(DocumentSnapshot doc){

    String title = doc["title"];
    String date = doc["writeDate"];
    String detail = doc["detail"];
    List receiveuserID = doc["receiveuser"];

    showDialog(
        context: context,
        builder: (context) {

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                ),
                title: Text(
                  "상세보기",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Container(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "제목 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "공유 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                receiveuserID.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "공유 일자 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                date.toString().substring(0, 10),
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "상세 내용 : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                detail,
                                style: TextStyle(
                                  fontSize: 20,
                                  //fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),
                      ]
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          "확인",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ],
                  )
                ],
              );
            },
          );
        }
    );
  }
}
