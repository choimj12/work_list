import 'dart:js';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_worklist_page.dart';
import 'write_sharelist_page.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'update_worklist_page.dart';

class DetailPage {
  void workListDetail(BuildContext context, String docID, String title, String company, String task, String workdate, String detail, bool complete){

    bool checkValue = complete;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            color: Colors.deepPurple,
            child: Text(
              "상세보기"
            ),
          ),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        "제목 : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
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
                        "장소 : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        company,
                        style: TextStyle(
                          fontSize: 15,
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
                        "작업내용 : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task,
                        style: TextStyle(
                          fontSize: 15,
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
                        "업무 일자 : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        workdate.toString().substring(0, 10),
                        style: TextStyle(
                          fontSize: 15,
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
                        "완료 여부 : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: checkValue == false ? Colors.red : null,
                        ),

                        onPressed: () {

                        },

                      )
                    )
                  ],
                )

              ],
            ),
          ),
        );
      }
    );
  }
}