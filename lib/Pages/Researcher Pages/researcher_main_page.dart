import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Pages/Researcher%20Pages/patients_filter_page.dart';
import 'package:hqc_flutter/Widgets/main_page_app_bar.dart';
import 'package:hqc_flutter/Widgets/main_page_tile.dart';
import '../../main.dart';
import '../edit_info_page.dart';
import '../login_page.dart';

class ResearcherMainPage extends StatefulWidget {
  const ResearcherMainPage({Key key}) : super(key: key);

  @override
  _ResearcherMainPageState createState() => _ResearcherMainPageState();
}

class _ResearcherMainPageState extends State<ResearcherMainPage> {
  @override
  Widget build(BuildContext context) {
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
          'باحث',
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
                  text: 'تقارير المرضى',
                  icon: Icons.search,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => PatientsFilterPage(),
                      ),
                    );
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
