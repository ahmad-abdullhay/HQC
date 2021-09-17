import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Pages/Patient%20Pages/patient_main_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

class PatientRegisterPage extends StatefulWidget {
  final Patient user;

  const PatientRegisterPage({Key key, this.user}) : super(key: key);

  @override
  _PatientRegisterPageState createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isRegistering = false;
  bool isMale = true;
  int age = 30;
  bool isPregnant = false;
  bool isSmoker = false;
  int weight = 60;
  bool dataAccept = false;
  final userRef = FirebaseFirestore.instance.collection('users');

  List<String> diseases = [
    'مرض الربو',
    'السكري',
    'الضغط',
    'مرض القلب',
    'امراض الكلى',
  ];
  List<String> selectedDiseases = [];
  registerUsingFirebase() async {
    setState(() {
      isRegistering = true;
    });
    var user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: '${widget.user.id}@HQCdumpEmails.com',
        password: widget.user.password,
      ))
          .user;
    } catch (ex) {
      print(ex);
      user = null;
      String errorString;
      switch (ex.message) {
        case 'The email address is already in use by another account.':
          errorString = "Email already in use";
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorString = "Network Error";
          break;
        default:
          print('Case ${ex.message} is not jet implemented');
      }
      Toast.show(errorString, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
    if (user != null) {
    } else {
      setState(() {
        isRegistering = false;
      });
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();

    await userRef.doc(user.uid).set({
      "id": widget.user.id,
      "email": widget.user.email,
      "name": widget.user.name,
      "type": widget.user.type,
      "chatsList": [],
      "age": age,
      "gender": isMale,
      "isPregnant": isPregnant,
      "isSmoker": isSmoker,
      "weight": weight,
      "diseases": selectedDiseases,
      "enterDate": DateTime.now(),
      "biometricsList": [],
      "prescription": [],
    });
    widget.user.firebaseID = user.uid;
    print(user.uid);
    widget.user.age = age;
    widget.user.gender = isMale;
    widget.user.isPregnant = isPregnant;
    widget.user.isSmoker = isSmoker;
    widget.user.enterDate = DateTime.now();
    widget.user.weight = weight;
    widget.user.diseases = selectedDiseases;
    widget.user.prescriptionList = [];
    widget.user.biometricsList = [];
    Main.currentUser = widget.user;
    setState(() {
      isRegistering = false;
    });

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => PatientMainPage(
            patient: widget.user,
          ),
        ),
        (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: isRegistering,
          child: Center(
            child: Form(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الجنس',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isMale = true;
                                });
                              },
                              child: Text(
                                'ذكر',
                                style: TextStyle(
                                    color:
                                        isMale ? Colors.white : Colors.black),
                              ),
                              color: isMale
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isMale = false;
                                });
                              },
                              child: Text(
                                'انثى',
                                style: TextStyle(
                                    color:
                                        !isMale ? Colors.white : Colors.black),
                              ),
                              color: !isMale
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            )
                          ],
                        ),
                        Text(
                          'العمر',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Slider(
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context).primaryColor,
                          min: 0,
                          max: 120,
                          divisions: 120,
                          label: age.toString(),
                          value: age.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              age = value.toInt();
                            });
                          },
                        ),
                        Text(
                          'حامل',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isPregnant = false;
                                });
                              },
                              child: Text(
                                'لا',
                                style: TextStyle(
                                    color: !isPregnant
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              color: !isPregnant
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isPregnant = true;
                                });
                              },
                              child: Text(
                                'نعم',
                                style: TextStyle(
                                    color: isPregnant
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              color: isPregnant
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            )
                          ],
                        ),
                        Text(
                          'مدخن',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Row(
                          children: [
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isSmoker = false;
                                });
                              },
                              child: Text(
                                'لا',
                                style: TextStyle(
                                    color: !isSmoker
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              color: !isSmoker
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isSmoker = true;
                                });
                              },
                              child: Text(
                                'نعم',
                                style: TextStyle(
                                    color:
                                        isSmoker ? Colors.white : Colors.black),
                              ),
                              color: isSmoker
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            )
                          ],
                        ),
                        Text(
                          'الوزن',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Slider(
                          min: 0,
                          max: 120,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context).primaryColor,
                          divisions: 120,
                          label: weight.toString(),
                          value: weight.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              weight = value.toInt();
                            });
                          },
                        ),
                        Text(
                          'الأمراض المزمنة',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: DropdownButton(
                            underline: SizedBox.shrink(),
                            value: diseases[0],
                            onChanged: (newValue) {
                              setState(() {
                                if (!selectedDiseases.contains(newValue))
                                  selectedDiseases.add(newValue);
                              });
                            },
                            items: diseases.map((c) {
                              return DropdownMenuItem(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 40, right: 4, top: 8, bottom: 8),
                                  child: new Text(
                                    c,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                value: c,
                              );
                            }).toList(),
                          ),
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: selectedDiseases.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(children: [
                                    Expanded(
                                      child: Container(
                                        child: Text(selectedDiseases[index]),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          selectedDiseases.removeAt(index);
                                        });
                                      },
                                    )
                                  ]));
                            }),
                        CheckboxListTile(
                          activeColor: Theme.of(context).primaryColor,
                          title: Text(
                            'اوافق على نشر بياناتي للباحثين',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          value: dataAccept,
                          onChanged: (value) {
                            setState(() {
                              dataAccept = value;
                            });
                          },
                        ),
                        Center(
                          child: Container(
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                registerUsingFirebase();
                              },
                              child: Text('انشاء الحساب'),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
