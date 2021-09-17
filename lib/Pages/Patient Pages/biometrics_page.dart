import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/biometrics.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Widgets/main_page_app_bar.dart';


class BiometricsPage extends StatefulWidget {
  final Biometrics biometrics;
  final Patient patient;
  const BiometricsPage({Key key, @required this.biometrics, this.patient})
      : super(key: key);

  @override
  _BiometricsPageState createState() => _BiometricsPageState();
}

class _BiometricsPageState extends State<BiometricsPage> {
  final userRef = FirebaseFirestore.instance.collection('users');
  Future<void> writeToFirebase() async {
    
    widget.patient.biometricsList.add(widget.biometrics);
    await userRef.doc(widget.patient.firebaseID).set({
      "biometricsList": Biometrics.toFirebase(widget.patient.biometricsList),
    }, SetOptions(merge: true));
    print(widget.patient.biometricsList);
  }

  @override
  void initState() {
  
    super.initState();   writeToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainPageAppBar(
        height: 180,
        columnWidgets: [
          SizedBox(
            height: 100,
          ),
          Text(
            'العلامات الحيوية',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        ],
      ).build(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter, 
                    colors: [
                       Colors.orange[400],
                      Colors.orange[50]
                    ], 
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                width: MediaQuery.of(context).size.width * 0.475,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.show_chart),
                    Text('معدل التنفس',style: TextStyle(color: Colors.white,fontSize: 24),),
                    Text('${widget.biometrics.breathingRate}B/m',style: TextStyle(color: Colors.black,fontSize: 24),)
                  ],
                ),
              ),
              Container(
                 decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter, 
                    colors: [
                       Colors.orange[400],
                      Colors.orange[50]
                    ], 
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 250,
                width: MediaQuery.of(context).size.width * 0.475,
             child:  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.ac_unit),
                      Text('درجة الحرارة',style: TextStyle(color: Colors.white,fontSize: 24),),
                      Text('${widget.biometrics.temperature}C',style: TextStyle(color: Colors.black,fontSize: 24))
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
