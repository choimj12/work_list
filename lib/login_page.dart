import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'account_create.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

LoginPageState pageState;

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    pageState = LoginPageState();
    return pageState;
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _idCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();

  FocusNode _idFocus = FocusNode();
  FocusNode _pwFocus = FocusNode();

  bool doRemember = false;
  bool obscurePassword = true;

  FirebaseProvider fp;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  void _signIn() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("   Signing-In...")
          ],
        ),
      ));
    bool result = await fp.signInWithEmail(_idCon.text, _pwCon.text);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == false) showLastFBMessage();
  }

  showLastFBMessage() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red[400],
        duration: Duration(seconds: 10),
        content: Text(fp.getLastFBMessage()),
        action: SnackBarAction(
          label: "Done",
          textColor: Colors.white,
          onPressed: () {},
        ),
      )
      );
  }

  hidePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  getRememberInfo() async {
    logger.d(doRemember);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doRemember = (prefs.getBool("doRemember") ?? false);
    });

    if(doRemember) {
      setState(() {
        _idCon.text = (prefs.getString("userEmail") ?? "");
        _pwCon.text = (prefs.getString("userPasswd") ?? "");
      });
    }
  }

  setRememberInfo() async {
    logger.d(doRemember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("doRemember", doRemember);

    if(doRemember) {
      prefs.setString("userEmail", _idCon.text);
      prefs.setString("userPasswd", _pwCon.text);
    }
  }


  @override
  void initState() {
    super.initState();
    getRememberInfo();
  }

  @override
  void dispose() {
    setRememberInfo();
    _idCon.dispose();
    _pwCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          print("hihi");
        },

        child: Container(
          color: Colors.white,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "업무 일정 관리",
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 40
                  ),
                ),

                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _idCon,
                          focusNode: _idFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).requestFocus(_pwFocus);
                          },

                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                  Icons.mail
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2
                                  )
                              ),
                              border: OutlineInputBorder(),
                              labelText: "ID"
                          ),

                          validator: (value) {
                            if(value.isEmpty) {
                              return "이메일을 입력하세요";
                            } else
                              return null;
                          },
                        ),

                        TextFormField(
                          controller: _pwCon,
                          focusNode: _pwFocus,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                  Icons.lock
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2
                                  )
                              ),
                              border: OutlineInputBorder(),
                              labelText: "PW",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  hidePassword();
                                },
                              )
                          ),

                          validator: (value) {
                            if(value.isEmpty) {
                              return "비밀번호를 입력하세요";
                            } else
                              return null;
                          },
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: RaisedButton(
                              color: Colors.deepPurple,
                              child: Text(
                                "로그인",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                if(_formKey.currentState.validate()){
                                  _signIn();
                                }
                              }
                          ),
                        )
                      ].map((c) {
                        return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: c
                        );
                      }).toList(),
                    )
                ),

                Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.deepPurple,
                      value: doRemember,
                      onChanged: (newValue) {
                        setState(() {
                          doRemember = newValue;
                        });
                      },
                    ),
                    Text(
                      "아이디 저장",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple
                      ),
                    )
                  ],
                ),

                Divider(
                  thickness: 2,
                  //color: Colors.deepPurpleAccent,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "회원가입",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountCreatePage()));
                      },

                    ),

                    FlatButton(
                      child: Text(
                        "비밀번호 찾기",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16
                        ),
                      ),
                    )
                  ],
                )

              ].map((c) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10
                  ),
                  child: c,
                );
              }).toList()
          ),
        ),
      ),
    );
  }
}
