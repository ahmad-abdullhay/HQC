import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/doctor.dart';
import 'package:hqc_flutter/Models/nurse.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Models/user.dart';
import 'package:hqc_flutter/Pages/chat_page.dart';

class PatientChatPage extends StatefulWidget {
  final Patient patient;

  const PatientChatPage({Key key, this.patient}) : super(key: key);
  @override
  _PatientChatPageState createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  List<User> userList;
  List<dynamic> chatsList;
  bool isLoading = true;
  Future<void> getUserList() async {
    setState(() {
      isLoading = true;
    });
    userList = [];
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patient.firebaseID)
        .get();

    chatsList = doc['chatsList'];
    for (String id in chatsList) {
      DocumentSnapshot chatDoc =
          await FirebaseFirestore.instance.collection('chats').doc(id).get();
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(chatDoc['ID'])
          .get();
      if (doc['type'] == 'دكتور')
        userList.add(Doctor.fromDocument(doc, chatDoc['ID']));
      else
        userList.add(Nurse.fromDocument(doc, chatDoc['ID']));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الدردشات',
        ),
        actions: [
          IconButton(icon:Icon( Icons.refresh),
          onPressed: () {if (!isLoading)getUserList();} ,
          )
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Container()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                chatsList.length != 0 ?  Expanded(
                    child: ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return UserChatListTile(
                              user: userList[index], chatId: chatsList[index]);
                        }),
                  ) :
                  Container(child: Text('عذراً لا يوجد محادثات \n انتظر قليلا وسيتحدث معك الطبيب المختص'),)
                ],
              ),
      ),
    );
  }
}

class UserChatListTile extends StatelessWidget {
  final User user;
  final String chatId;
  const UserChatListTile({Key key, this.user, this.chatId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(26.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ChatPage(
                      user: user,
                      chatId: chatId,
                    ),
              ));
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [Text(user.name), Text(user.type)],
            )),
      ),
    );
  }
}
