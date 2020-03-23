import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class writeShareListPage extends StatefulWidget{
  @override
  writeShareListPageState createState() => writeShareListPageState();
}

class writeShareListPageState extends State<writeShareListPage> {

  String fnTitle = "title"; //제목
  String fnDetail = "detail"; //상세내용
  String fnWriteDate = "writeDate"; //공지 작성일
  String fnName = "name"; //작성자 이메일
  String fnToken = "token"; //FCM 토큰값
  String fnWriterName = "writerName"; //작성자 이름 ;
  String fnFlag = "flag";

  String fnCount = "count";
  String fnConfirm = "confirm";

  String fnReceiveUser ="receiveuser";

  FirebaseProvider fp;
  Firestore _db = Firestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  Map<String, bool> _sToken = Map();
  Map<String, bool> _sDocumentID = Map();
  Map<String, bool> _sDocumentName = Map();

  List<String> userName = List<String> ();
  List<String> userToken = List<String> ();
  List<String> userDocumentID = List<String> ();

  String writerName;

  int num = 0;

  TextEditingController _titleCon = TextEditingController();
  TextEditingController _detailCon = TextEditingController();

  final HttpsCallable sendFCM = CloudFunctions.instance
      .getHttpsCallable(functionName: 'sendFCM')
    ..timeout = const Duration(seconds: 30);

  void sendSampleFCMtoSelectedDevice() async {
    List<String> tokenList = List<String>();
    _sToken.forEach((String key, bool value) {
      if (value) {
        tokenList.add(key);
      }
    });
    if (tokenList.length == 0) return;
    final HttpsCallableResult result = await sendFCM.call(
      <String, dynamic>{
        fnToken: tokenList,
        "title": _titleCon.text,
        "body": _detailCon.text,
      },
    );
  }
  
  void updateUserInfo() async {
    if(fp.getUser() == null) return;
    String tok = await _fcm.getToken();
    if(tok == null) return;
    
    var user = _db.collection("user").document(fp.getUser().email);

    await user.updateData({
      fnToken: tok
    });
  }

  void uploadData(String title, String detail) {
    List<String> documentID = List<String>();
    List<String> shareuser = List<String> ();
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    print(_sDocumentID);
    _sDocumentID.forEach((String key, bool value){
      if(value) {
        documentID.add(key);
      }
    });
    _sDocumentName.forEach((String key, bool value){
      if(value){
        shareuser.add(key);
      }
    });


    _db.collection("user").document(fp.getUser().email).collection("share").add({
      fnTitle : title,
      fnDetail : detail,
      fnWriteDate : date.toString(),
      fnName : fp.getUser().email,
      fnWriterName : writerName,
      fnFlag : "me",
      fnCount : documentID.length,
      fnReceiveUser : shareuser,
    }).then((doc){
      documentID.forEach((id){
        _db.collection("user").document(id).collection("share").document(doc.documentID).setData({
          fnTitle : title,
          fnDetail : detail,
          fnWriteDate : date.toString(),
          fnName : fp.getUser().email,
          fnWriterName : writerName,
          fnFlag : "other",
          fnConfirm : false,
        });
      });
    });

    print("업로드 완료");
  }

  @override
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
    updateUserInfo();
    fp = Provider.of<FirebaseProvider>(context);

    _db.collection("user").document(fp.getUser().email).get().then((DocumentSnapshot doc){
      writerName = doc["name"];
      print(doc["name"]);
    });

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
              "공유 리스트 작성"
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
              child: Column(
                  children: <Widget>[
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
                          flex: 7,
                          child: TextFormField(
                            controller: _titleCon,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
                                )
                            ),
                          ),
                        )
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text(
                            "내용",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: TextFormField(
                            controller: _detailCon,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
                                )
                            ),
                          ),
                        )
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text(
                            "공유",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(32.0),
                                  border: Border.all(
                                      color: Colors.deepPurple,
                                      width: 2
                                  )
                              ),
                              child: StreamBuilder<QuerySnapshot> (
                                stream: _db.collection("user").snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  print("스냅샷");
                                  print(snapshot);

                                  userName = [];
                                  userToken = [];
                                  userDocumentID = [];
                                  snapshot.data.documents.forEach((DocumentSnapshot doc) {
                                    print(doc.documentID);
                                    if(doc.documentID != fp.getUser().email) {
                                      userName.add(doc[fnName]);
                                      userToken.add(doc[fnToken]);
                                      userDocumentID.add(doc.documentID);
                                      print(userName);
                                    }

                                    if(!_sToken.containsKey(doc[fnToken]) && doc.documentID != fp.getUser().email) {
                                      _sToken[doc[fnToken]] = false;
                                      _sDocumentID[doc.documentID] = false;
                                      _sDocumentName[doc[fnName]] = false;
                                    }
                                  });
                                  return GridView.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 10,
                                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                                      children: List.generate(userName.length, (index) {
                                        return CircleAvatar(
                                          child: InkWell(
                                            child: Text(
                                                userName[index]
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _sToken[userToken[index]] = !_sToken[userToken[index]];
                                                _sDocumentID[userDocumentID[index]] = !_sDocumentID[userDocumentID[index]];
                                                _sDocumentName[userName[index]] = !_sDocumentName[userName[index]];
                                              });
                                            },
                                          ),
                                          backgroundColor: _sToken[userToken[index]] == false ? Colors.deepPurple : Colors.amberAccent,
                                        );
                                      })
                                  );
                                },
                              )
                          ),
                        )
                      ],
                    ),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            child: RaisedButton(
                              color: Colors.deepPurple,
                              child: Text(
                                "취소",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),

                              onPressed: () {
                                Navigator.pop(context);
                              },
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
                                "작성",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),

                              onPressed: () {
                                sendSampleFCMtoSelectedDevice();
                                uploadData(_titleCon.text, _detailCon.text);
                                //Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ].map((c){
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: c,
                    );
                  }).toList()
              ),
            ),
          ),
        )
    );
  }
}