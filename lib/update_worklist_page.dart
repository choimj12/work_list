import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_list/list_page.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';



class updateWorkListPage extends StatefulWidget {
  SendData sendData;

  updateWorkListPage({Key key, @required this.sendData}) : super(key: key);

  @override
  updateWorkListPageState createState() => updateWorkListPageState ();
}

class updateWorkListPageState extends State<updateWorkListPage> {

  SendData popData;

  String fnTitle = "title"; //제목
  String fnCompany = "company";  //회사명
  String fnTask = "task"; //업무
  String fnDate = "date"; //업무일자
  String fnDetail = "detail";

  FirebaseProvider fp;
  DateTime date;

  uploadadData(String title, String company, String task, String detail){
    Firestore.instance.collection("work").document(widget.sendData.doc).updateData({
      fnTitle : title,
      fnDate : date.toString(),
      fnCompany : company,
      fnTask : task,
      fnDetail : detail,
    });
  }

  void callDatePicker() async {
    var order = await getDate();
    if(order == null){
      order = date;
    }
    setState(() {
      print("시간");
      print(date);
      date = order;
    });
  }

  Future<DateTime> getDate(){
    return showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light(),
            child: child,
          );
        }
    );
  }

  TextEditingController _titleCon = TextEditingController();
  TextEditingController _locationCon = TextEditingController();
  TextEditingController _taskCon = TextEditingController();
  TextEditingController _detailCon = TextEditingController();

  List<String> _locationName = ['AIA', '후지 제록스', '농협', '사무실', '기타'];
  String _selectedlocation;

  List<String> _taskName = ['ER2 이슈지원', 'ER2 프로젝트', '제안서 작성', 'PoC', 'PIC 지원', '기타'];
  String _selectedtask;

  @override

  Widget build(BuildContext context) {
    popData = widget.sendData;

    if(date == null) {
      setState(() {
        date = DateTime.parse(widget.sendData.workdate);
      });
    }

    setState(() {
      _titleCon.text = widget.sendData.title;
      _detailCon.text = widget.sendData.detail;
    });

    if(_selectedlocation == null) {
      setState(() {
        _selectedlocation = widget.sendData.company;
      });
    }

    if(_selectedtask == null) {
      setState(() {
        _selectedtask = widget.sendData.task;
      });
    }

    print(_selectedlocation);
    fp = Provider.of<FirebaseProvider>(context);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
              "업무 리스트 수정"
          ),
        ),
        body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                color: Colors.white,
                child: Form(
                  child: Column(
                    children: <Widget>[

                      //제목
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "제목",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _titleCon,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),


                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "업무 일자",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 50,
                              child: RaisedButton(
                                onPressed: () {
                                  callDatePicker();
                                },
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    side: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),

                                child: Text(
                                    date.month.toString() + "월 " + date.day.toString() + "일"
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),

                      //업무 장소
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "업무 장소",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                              value: _selectedlocation,
                              onChanged: (value) {
                                setState(() {
                                  _selectedlocation = value;
                                });
                              },
                              items: _locationName.map((name) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: 150,
                                    child: Text(name),
                                  ),
                                  value : name,
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),

                      _selectedlocation == "기타" ?
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "업무 장소 입력",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _locationCon,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ) : Row(),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),

                      //업무 구분
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "업무 구분",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField(

                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                              value: _selectedtask,
                              onChanged: (value) {
                                setState(() {
                                  print(_selectedtask);
                                  _selectedtask = value;
                                });
                              },
                              items: _taskName.map((name) {
                                return DropdownMenuItem(
                                  child: SizedBox(
                                    width: 150,
                                    child: Text(name),
                                  ),
                                  value : name,
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),

                      _selectedtask == "기타" ?
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "업무 구분 입력",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _taskCon,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ) : Row(),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "상세내용",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: _detailCon,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                      ),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 150,
                              child: RaisedButton(
                                child: Text(
                                  "취소",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 30),
                            ),

                            SizedBox(
                              width: 150,
                              child: RaisedButton(
                                color: Colors.deepPurple,
                                child: Text(
                                  "수정",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    popData.title = _titleCon.text;
                                    popData.company = _selectedlocation;
                                    popData.task = _selectedtask;
                                    popData.detail = _detailCon.text;
                                    popData.workdate = date.toString();
                                  });
                                  uploadadData(_titleCon.text, _selectedlocation, _selectedtask, _detailCon.text);
                                  Navigator.pop(context, popData);
                                  print("테스트 : " + _titleCon.text);
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
        )
    );
  }
}