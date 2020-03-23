import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:work_list/list_page.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'update_worklist_page.dart';

class WorkListPage extends StatefulWidget {
@override
WorkListPageState createState() => WorkListPageState ();
}

class WorkListPageState extends State<WorkListPage> {
  SendData listData;

  CalendarController _calendarController;

  FirebaseProvider fp;
  Firestore _db = Firestore.instance;

  DateTime nowDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  String fnComplete = "complete";
  bool test = false;

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

            Text(
              "일정 목록",
              style: TextStyle(
                fontSize: 27,
                color: Colors.deepPurple
              ),
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
              stream: _db.collection("work").where("user", isEqualTo: fp.getUser().email).where("date", isEqualTo: nowDate.toString()).snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {

                if(snapshot.connectionState == ConnectionState.waiting){
                  return new Center(child: new CircularProgressIndicator());
                }

                var workList = snapshot.data.documents ?? [];

                if(workList.length == 0) {
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
                              ) ,
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
        ),
      ),
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
}
