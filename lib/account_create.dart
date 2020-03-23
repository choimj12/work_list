import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';


AccountCreatePageState pageState;

class AccountCreatePage extends StatefulWidget {
  @override
  AccountCreatePageState createState() {
    pageState = AccountCreatePageState();
    return pageState;
  }
}

class AccountCreatePageState extends State<AccountCreatePage> {
  bool check = false;

  //스낵바 출력용
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Form 유효성 체크 용
  final _formKeyEamil = GlobalKey<FormState>();
  final _formKeyPasswd = GlobalKey<FormState>();
  final _formKeyName = GlobalKey<FormState>();

  //프로바이더
  FirebaseProvider fp;

  //Firebase DB 인스턴스
  final Firestore _db = Firestore.instance;

  //'user' 컬렉션 항목
  final String colName = "user"; //컬렉션 이름
  final String fnName = "name"; //이름
  final String fnTeam = "team"; //팀명

  //Email 중복 여부 (false : 중복 값 있음, true : 중복 값 없음)
  bool _duplicateIDCheckValue = false;

  //Email 유효성 판단 (false : 유효성 불만족, true : 유효성 만족)
  bool _validEmailCheckValue = false;

  //Password 숨기기 기능 on/off (false : 패스워드 보임, true : 패스워드 숨김)
  bool _obscurePassword = true;

  //Password 유효성 판단 (false : 유효성 불만족, true : 유효성 만족)
  bool _validPasswordCheckValue = false;

  //회원가입 정보입력 란
  TextEditingController _mailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  TextEditingController _nameCon = TextEditingController();

  //회원가입 정보입력란 포커스
  FocusNode _mailFocus = FocusNode();
  FocusNode _pwFocus = FocusNode();
  FocusNode _nameFocus = FocusNode();

  //팀이름 드롭다운 메뉴
  List<String> _teamName = ['영업팀', '모바일개발팀', '엔지니어팀'];
  String _selectedTeam = "영업팀";

  void dispose() {
    _mailCon.dispose();
    _pwCon.dispose();
    _nameCon.dispose();
    super.dispose();
  }

  //'user' 컬렉션에 데이터 추가 함수
  void createUser(String email, String name, String team) {
    _db.collection("user").document(email).setData({
      fnName : name,
      fnTeam : team,
    });
    print("생성완료");
  }

  //Email 중복 체그 함수
  bool duplicateIDCheck(String inputEmail) {
    print("중복체크실행");
    var temp;
    bool a = false;
    _db.collection("user").getDocuments().then((QuerySnapshot snapshot) {
      for(int i = 0; i < snapshot.documents.length; i++) {
        temp = snapshot.documents.elementAt(i).documentID; //'user' 컬렉션 문서 ID를 temp 변수에 저장
        print(temp);
        print(inputEmail);
        //Email이 중복되면 중복체크값 false
        if(inputEmail == temp) {
          a = true;
          break;
        }
      }

      if(a == true){
        setState(() {
          _duplicateIDCheckValue = false;
        });
        return _duplicateIDCheckValue;
      }
      else
        setState(() {
          _duplicateIDCheckValue = true;
        });

      return _duplicateIDCheckValue;
    });
  }

  //Password 숨기기 기능 함수
  void hidePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  //Email 유효성 체크 함수
  void validEmailCheck(String inputEmail) {
    RegExp emailRegExp = RegExp(r'^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$'); //Email 정규식표현

    //Email 정규식표현에 맞을 때
    if(emailRegExp.hasMatch(inputEmail)) {
      setState(() {
        _validEmailCheckValue = true;
      });
    }
    else
      setState(() {
        _validEmailCheckValue = false;
      });
  }

  //Password 유효성 체크 함수
  void validPasswordCheck(String inputPassword) {
    print("start");
    RegExp passwordRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$'); //Password 정규식표현 (문자, 숫자 1나씩 최소 6자리)

    //정규식표현에 적합할 때
    if(passwordRegExp.hasMatch(inputPassword)) {
      setState(() {
        _validPasswordCheckValue = true;
      });
    }

    else{
      setState(() {
        _validPasswordCheckValue = false;
      });
    }
  }

  //회원가입
  void _signUP() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("   Signing-Up...")
          ],
        ),
      ));

    bool result = await fp.signUpWithEmail(_mailCon.text, _pwCon.text);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if(result) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(fp == null) {
      fp = Provider.of<FirebaseProvider>(context);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false, //키보드가 화면 밀지 않도록 함
      body: GestureDetector(
        //텍스트 필드 외 클릭시 키보드 숨김
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },

        //스크롤 화면
        child: CustomScrollView(
          slivers: <Widget>[
            //앱바
            SliverAppBar(
              expandedHeight: 115,
              pinned: true, // 스크롤 위로 올릴 때 Appbar 남아 있음 (false : Appbar 사라짐)

              //로그인 화면으로 가기 버튼
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 35,
                ),
                onPressed: () {
                  //화면 이동 함수
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),

              //페이지 이름
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true, //타이틀 중간으로 이동
                titlePadding: EdgeInsets.only(bottom: 13),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 80),
                    ),
                    Text(
                      "회원가입",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //본문
            SliverFillRemaining(
                child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "이메일",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Expanded(
                              flex: 7,
                              child: Form(
                                key: _formKeyEamil,
                                child: TextFormField(
                                  controller: _mailCon,
                                  focusNode: _mailFocus,
                                  textInputAction: TextInputAction.next,

                                  onFieldSubmitted: (term) {
                                    FocusScope.of(context).requestFocus(_pwFocus);
                                  },

                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2
                                          )
                                      ),
                                      border: OutlineInputBorder(),
                                      labelText: "Email",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            Icons.check,
                                            color: _validEmailCheckValue == false ? Colors.grey : check == true && _duplicateIDCheckValue == true ? Colors.green : Colors.red
                                        ),
                                        onPressed: _validEmailCheckValue == false ? null : () {
                                          setState(() {
                                            check = true;
                                          });
                                          if(check == true){
                                            _formKeyEamil.currentState.validate();
                                          }
                                        },
                                      )
                                  ),

                                  validator: (value) {
                                    if(value.isEmpty) {
                                      return "이메일을 입력하세요";
                                    }

                                    else if(value.isNotEmpty) {
                                      validEmailCheck(value);
                                      if(_validEmailCheckValue != true) {
                                        return "이메일 형식이 올바르지 않습니다.";
                                      }
                                      else {
                                        if(check == false) {
                                          return "중복확인이 필요합니다.";
                                        }

                                        else {
                                          if(_duplicateIDCheckValue == false) {
                                            return "이미 사용중인 아이디입니다.";
                                          }
                                        }
                                      }
                                    }
                                    return null;
                                  },

                                  onChanged: (text) {
                                    setState(() {
                                      check = false;
                                      _duplicateIDCheckValue = false;
                                    });
                                    duplicateIDCheck(text);
                                    _formKeyEamil.currentState.validate();
                                  },
                                ),
                              )
                          )
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "비밀번호",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Expanded(
                              flex: 7,
                              child: Form(
                                key: _formKeyPasswd,
                                child: TextFormField(
                                  controller: _pwCon,
                                  focusNode: _pwFocus,
                                  textInputAction: TextInputAction.next,
                                  obscureText: _obscurePassword,

                                  onFieldSubmitted: (term) {
                                    FocusScope.of(context).requestFocus(_nameFocus);
                                  },

                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2
                                          )
                                      ),

                                      border: OutlineInputBorder(),
                                      labelText: "Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          hidePassword();
                                        },
                                      )
                                  ),

                                  validator: (value) {
                                    if(value.isEmpty) {
                                      return "비밀번호를 입력하세요";
                                    }
                                    else if(value.isNotEmpty) {
                                      validPasswordCheck(value);

                                      if(_validPasswordCheckValue != true) {
                                        return "비밀번호는 문자, 숫자를 포함하여 6자리 이상입니다.";
                                      }
                                    }
                                    return null;
                                  },

                                  onChanged: (text) {
                                    _formKeyPasswd.currentState.validate();
                                  },
                                ),
                              )
                          )
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "이름",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Expanded(
                              flex: 7,
                              child: Form(
                                key: _formKeyName,
                                child: TextFormField(
                                  controller: _nameCon,
                                  focusNode: _nameFocus,
                                  textInputAction: TextInputAction.done,

                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2
                                          )
                                      ),

                                      border: OutlineInputBorder(),
                                      labelText: "Name"
                                  ),

                                  validator: (value) {
                                    if(value.isEmpty) {
                                      return "이름을 입력하세요";
                                    }
                                    else
                                      return null;
                                  },

                                  onChanged: (text) {
                                    _formKeyName.currentState.validate();
                                  },
                                ),
                              )
                          )
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "팀명",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Expanded(
                              flex: 7,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2
                                        )
                                    ),
                                    border: OutlineInputBorder(),
                                    labelText: "Team"
                                ),

                                value: _selectedTeam,

                                onChanged: (value) {
                                  setState(() {
                                    _selectedTeam = value;
                                  });
                                },

                                items: _teamName.map((name) {
                                  return DropdownMenuItem(
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(name),
                                    ),
                                    value: name,
                                  );
                                }).toList(),
                              )
                          )
                        ],
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          color: Colors.deepPurple,
                          child: Text(
                            "회원가입",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),

                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _signUP();
                            createUser(_mailCon.text ,_nameCon.text, _selectedTeam);
                          },
                        ),
                      )
                    ].map((c) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10
                        ),
                        child: c,
                      );
                    }).toList()
                )
            )
          ],
        ),
      ),
    );
  }
}
