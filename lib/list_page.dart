import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_worklist_page.dart';
import 'write_sharelist_page.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'update_worklist_page.dart';

class SendData {
  String doc;
  String title;
  String company;
  String task;
  String workdate;
  String detail;

  SendData(this.doc, this.title, this.workdate, this.company, this.detail, this.task);
}

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  String fnComplete = "complete";

  bool test = false;
  bool test2 = false;

  Firestore _db = Firestore.instance;
  FirebaseProvider fp;
  FirebaseMessaging _fcm = FirebaseMessaging();

  int i = 0;

  void initState() {
    super.initState();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message["notification"]["title"]),
              subtitle: Text(message["notification"]["body"]),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      },

      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },

      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            //color: Colors.blue,
            child: workList(),
          ),

          Expanded(
            //color: Colors.blue,
            child: noticeList(),
          )
        ],
      ),
    );
  }

  Widget workList() {

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child:Padding(
            padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(
                    "오늘 일정",
                    style: TextStyle(
                        fontSize: 27,
                        color: Colors.deepPurple
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 27,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute (builder: (context) => writeWorkListPage())
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),

        Divider(
          height: 1.0,
          color: Colors.deepPurple,
          thickness: 2,
          endIndent: 200,
        ),

        Padding(
          padding: EdgeInsets.only(top: 5),
        ),

        StreamBuilder(
            stream: _db.collection("work").where("user", isEqualTo: fp.getUser().email).where("date", isEqualTo: date.toString()).snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    child: Center(child: new CircularProgressIndicator())
                );
              }

              var workList = snapshot.data.documents ?? [];

              if (workList.length == 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 85),
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
                    itemCount: workList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                            leading: CircleAvatar(
                              radius: 23,
                              child: Text(
                                //회사명
                                workList.elementAt(index).data["company"],
                                style: TextStyle(
                                    fontSize: 15
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            title: Text(
                              //제목
                              workList.elementAt(index).data["title"],
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            trailing: Icon(
                                Icons.done,
                                color: workList.elementAt(index).data["complete"] == true ? Colors.green : Colors.red
                            ),
                            onTap: () {
                              setState(() {
                                test= workList.elementAt(index).data["complete"];
                              });

                              workListDetail(workList.elementAt(index));

                            }),
                      );
                    },
                  ),
                );
            }
        )
      ],
    );
  }

  Widget noticeList() {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(
                    "공지",
                    style: TextStyle(
                        fontSize: 27,
                        color: Colors.deepPurple
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 27,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => writeShareListPage())
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),

        Divider(
          height: 1.0,
          color: Colors.deepPurple,
          thickness: 2,
          endIndent: 200,
        ),

        Padding(
          padding: EdgeInsets.only(top: 5),
        ),

        StreamBuilder(
            stream: _db.collection("user").document(fp.getUser().email).collection("share").where("flag", isEqualTo: "other").where("writeDate", isEqualTo: date.toString()).snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {

              if(snapshot.connectionState == ConnectionState.waiting){
                return Container(
                    child: Center(child: new CircularProgressIndicator())
                );
              }

              var noticeList = snapshot.data.documents ?? [];

              if(noticeList.length == 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 90),
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
                            trailing: Icon(
                                Icons.done,
                                color: noticeList.elementAt(index).data["confirm"] == true ? Colors.green : Colors.red
                            ) ,
                            onTap: () {
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

                            }),
                      );
                    },
                  ),
                );
            }
        )
      ],
    );
  }

  void workListDetail(DocumentSnapshot doc){

    String title = doc["title"];
    String company = doc["company"];
    String task = doc["task"];
    String date = doc["date"];
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
                              "장소 : ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              company,
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
                              "업무 유형 : ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              task,
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
                              "업무 일자 : ",
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              "완료 여부 : ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                      Icons.cancel,
                                      color: test == false ? Colors.red : null
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      test = false;
                                    });
                                  },
                                ),

                                IconButton(
                                  icon: Icon(
                                      Icons.check,
                                      color: test == true ? Colors.green : null
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      test = true;
                                    });
                                  },
                                )
                              ],
                            )
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
                          "삭제",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple
                          ),
                        ),
                        onPressed: () {
                          _db.collection("work").document(doc.documentID).delete();
                          Navigator.pop(context);
                        },
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),

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
                          _db.collection("work").document(doc.documentID).updateData({
                            fnComplete : test
                          });
                          Navigator.pop(context);
                        },
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),

                      FlatButton(
                        child: Text(
                          "수정",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                          ),
                        ),
                        onPressed: () async {
                         SendData recive = await Navigator.push(
                              context,
                              MaterialPageRoute (builder: (context){
                                return updateWorkListPage(sendData: SendData(doc.documentID, title, date, company, detail, task));
                              })
                          );

                         setState(() {
                           title = recive.title;
                           task = recive.task;
                           detail = recive.detail;
                           company = recive.company;
                           date = recive.workdate;
                         });

                         print("제목" + recive.title);
                        },
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

}

