import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Widgets/main_page_app_bar.dart';
import 'package:hqc_flutter/Widgets/main_page_tile.dart';
import 'package:hqc_flutter/main.dart';
import '../chat_page.dart';
import '../edit_info_page.dart';
import '../login_page.dart';
import 'chart_page.dart';

class NurseMainPage extends StatefulWidget {
  final Patient patient;

  const NurseMainPage({Key key, this.patient}) : super(key: key);

  @override
  _NurseMainPageState createState() => _NurseMainPageState();
}

class _NurseMainPageState extends State<NurseMainPage> {
  @override
  Widget build(BuildContext context) {
    checkPrevChat() async {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(Main.currentUser.firebaseID)
          .get();

      List chatsList = doc['chatsList'];
      for (String id in chatsList) {
        DocumentSnapshot chatDoc =
            await FirebaseFirestore.instance.collection('chats').doc(id).get();
        if (chatDoc['patientID'] == widget.patient.firebaseID) return id;
      }
      return null;
    }

    return Scaffold(
      appBar: MainPageAppBar(
        height: 180,
        
        columnWidgets: [
                  SafeArea(
          child: Row(
            children: [
              IconButton(
                tooltip: 'تسجيل الخروج',
                icon: Icon(Icons.exit_to_app),
                color: Colors.white,
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } catch (ex) {}
                },
              ),
              IconButton(
                tooltip: 'تعديل البيانات',
                color: Colors.white,
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => EditInfoPage(
                                user: Main.currentUser,
                              ))).then((value) => {
                                setState((){})

                              });
                              
                },
              ),
            ],
          ),
        ),
        CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.orangeAccent[100],
            )),
        Text(
          Main.currentUser.name,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        Text(
          'ممرض',
          style: TextStyle(color: Colors.white),
        )
      ]).build(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainPageTile(
                  text: 'تواصل مع المريض',
                  icon: Icons.add_comment,
                  onTap: () async {
                    String id = await checkPrevChat();
                    if (id != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ChatPage(
                              user: widget.patient,
                              chatId: id,
                            ),
                          ));
                    } else {
                      // create new chat id
                      var chatDoc = await FirebaseFirestore.instance
                          .collection('chats')
                          .add({
                        'ID': Main.currentUser.firebaseID,
                        'patientID': widget.patient.firebaseID
                      });
                      // add chat id to patient table
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.patient.firebaseID)
                          .update({
                        "chatsList": FieldValue.arrayUnion([chatDoc.id]),
                      });
                      // add chat id to doctor table
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(Main.currentUser.firebaseID)
                          .update({
                        "chatsList": FieldValue.arrayUnion([chatDoc.id]),
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ChatPage(
                              user: widget.patient,
                              chatId: chatDoc.id,
                            ),
                          ));
                    }
                  },
                ),
                MainPageTile(
                  text: 'تقرير المريض',
                  icon: Icons.insert_chart,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ChartPage(
                                  patientBiometrics: widget.patient.biometricsList,
                                )));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
