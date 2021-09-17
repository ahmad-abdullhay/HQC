import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Pages/Patient%20Pages/Patient_chats_page.dart';
import 'package:hqc_flutter/Pages/Patient%20Pages/view_prescription_page.dart';
import 'package:hqc_flutter/Pages/edit_info_page.dart';
import 'package:hqc_flutter/Pages/login_page.dart';
import 'package:hqc_flutter/Widgets/main_page_app_bar.dart';
import 'package:hqc_flutter/Widgets/main_page_tile.dart';
import 'biometrics_mesurement_page.dart';

class PatientMainPage extends StatefulWidget {
  final Patient patient;

  const PatientMainPage({Key key, this.patient}) : super(key: key);

  @override
  _PatientMainPageState createState() => _PatientMainPageState();
}

class _PatientMainPageState extends State<PatientMainPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.patient.name);
    return Scaffold(
      appBar: MainPageAppBar(
        height: 225,
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
                                user: widget.patient,
                              ))).then((value) => {
                                setState((){})

                              });
                              
                },
              ),
            ],
          ),
        ),
        CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.orangeAccent[100],
            )),
        Text(
          widget.patient.name,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        Text(
          'مريض',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 55,
          height: 55,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 55,
                  height: 55,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    value: 12 / 16,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
              Center(
                child: Text(
                  (DateTime.now().difference(widget.patient.enterDate).inDays + 1)
                      .toString(),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ],
          ),
        )
      ]).build(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainPageTile(
                  text: 'قياس العلامات الحيوية',
                  icon: Icons.access_alarm,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                BiometricsMesurementPage(
                                  patient: widget.patient,
                                )));
                  },
                ),
                MainPageTile(
                  text: 'تواصل مع الطاقم الصحي',
                  icon: Icons.add_comment,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PatientChatPage(
                                  patient: widget.patient,
                                )));
                  },
                ),
                MainPageTile(
                  text: 'الوصفة الطبية',
                  icon: Icons.healing,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ViewPrescriptionPage(patient: widget.patient),
                        ));
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
