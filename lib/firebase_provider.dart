import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth fAuth = FirebaseAuth.instance;
  FirebaseUser _user;

  String _lastFirebaseResponse = ""; //에러 메시지 처리용

  FirebaseProvider() {
    logger.d("init FirebaseProvider");
    _prepareUser();
  }

  FirebaseUser getUser() {
    return _user;
  }

  void setUser(FirebaseUser value) {
    _user = value;
    notifyListeners();
  }

  //최근 로그인 정보 획득
  _prepareUser() {
    fAuth.currentUser().then((FirebaseUser currentUser) {
      setUser(currentUser);
    });
  }

  //이메일, 비밀번호로 Firebase 회원가입
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      AuthResult result = await fAuth.createUserWithEmailAndPassword(email: email, password: password);

      if(result.user != null) {
        //이메일 인증 메일 발송
        result.user.sendEmailVerification();
        logOut();
        return true;
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  //이메일, 비밀번호로 Firebase 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      var result = await fAuth.signInWithEmailAndPassword(email: email, password: password);
      if(result != null) {
        setUser(result.user);
        logger.d(getUser());
        return true;
      }
      return false;
    } catch (e) {
      logger.e(e.toString()); //logger.e : 에러로그
      List<String> result = e.toString().split(", ");

      if(result[0] == "ERROR_INVALID_EMAIL") {
        print("확인");
      }

      switch (e.code) {
        case "ERROR_INVALID_EMAIL" :
        case "ERROR_USER_NOT_FOUND" :
          setLastFBMessage("이메일을 다시 확인하세요");
          break;

        case "ERROR_WRONG_PASSWORD":
          setLastFBMessage("비밀번호가 올바르지 않습니다.");
          break;

        default :
          setLastFBMessage(result[0]);
      }
      return false;
    }
  }

  //Firebase 로그아웃
  logOut() async {
    await fAuth.signOut();
    setUser(null);
  }

  //비밀번호 재설정 메일 한글로 전송 시도
  sendPasswordRestEmailByKorean() async {
    await fAuth.setLanguageCode("ko");
    sendPasswordRestEmail();
  }

  //비밀번호 재설정 메일 전송
  sendPasswordRestEmail() async {
    fAuth.sendPasswordResetEmail(email: getUser().email);
  }

  //Firebase에서 수신한 메시지 설정
  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  //Firebase에서 수신한 메시지 반환 및 삭제
  getLastFBMessage() {
    String returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
  }
}