import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';

class PatientsFilterPage extends StatefulWidget {
  @override
  _PatientsFilterPageState createState() => _PatientsFilterPageState();
}

class _PatientsFilterPageState extends State<PatientsFilterPage> {
  bool isMale = false;
  bool isPregnant = false;
  bool isSmoker = false;
  int minAge = 10;
  int maxAge = 60;
  int minWeight = 10;
  int maxWeight = 100;
  int result ;
  List<String> diseases = [
    'مرض الربو',
    'السكري',
    'الضغط',
    'مرض القلب',
    'امراض الكلى',
  ];
  List<String> selectedDiseases = [

  ];
  List<Patient> patientUserList = [];
  bool isLoading = true;
  String disease = 'مرض الربو';
  getPatientList() async {
    setState(() {
      isLoading = true;
    });
    final usersRef = FirebaseFirestore.instance.collection('users');
    QuerySnapshot allNames = await usersRef.get();
    for (int i = 0; i < allNames.docs.length; i++) {
      var a = allNames.docs[i];
      if (a['type'] == 'مريض') {
        Patient patient = Patient.fromDocument(a, a.id);
        patientUserList.add(patient);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void initState() {
    getPatientList();
    super.initState();
  }
  bool searchInDiseases(Patient patient){
    if (selectedDiseases.length == 0)
    return true;
    for (String disease in selectedDiseases){
      if (patient.diseases.contains(disease))
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                        style: TextStyle(color: Theme.of(context).primaryColor),
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
                                  color: isMale ? Colors.white : Colors.black),
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
                                  color: !isMale ? Colors.white : Colors.black),
                            ),
                            color: !isMale
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          )
                        ],
                      ),
                      Text(
                        'العمر',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      RangeSlider(
                        labels:
                            RangeLabels(minAge.toString(), maxAge.toString()),
                        onChanged: (value) {
                          setState(() {
                            minAge = value.start.toInt();
                            maxAge = value.end.toInt();
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).primaryColor,
                        min: 0,
                        max: 120,
                        divisions: 120,
                        values:
                            RangeValues(minAge.toDouble(), maxAge.toDouble()),
                      ),
                      Text(
                        'حامل',
                        style: TextStyle(color: Theme.of(context).primaryColor),
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
                                  color:
                                      isPregnant ? Colors.white : Colors.black),
                            ),
                            color: isPregnant
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          )
                        ],
                      ),
                      Text(
                        'مدخن',
                        style: TextStyle(color: Theme.of(context).primaryColor),
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
                                  color:
                                      !isSmoker ? Colors.white : Colors.black),
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
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      RangeSlider(
                        labels: RangeLabels(
                            minWeight.toString(), maxWeight.toString()),
                        onChanged: (value) {
                          setState(() {
                            minWeight = value.start.toInt();
                            maxWeight = value.end.toInt();
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).primaryColor,
                        min: 0,
                        max: 120,
                        divisions: 120,
                        values: RangeValues(
                            minWeight.toDouble(), maxWeight.toDouble()),
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
                      Center(
                        child: Container(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              int counts = 0;
                              for (Patient patient in patientUserList) {
                                if (patient.gender == isMale &&
                                    patient.age.toInt() >= minAge &&
                                    patient.age.toInt() <= maxAge &&
                                    patient.isPregnant == isPregnant &&
                                    patient.isSmoker == isSmoker &&
                                    patient.weight.toInt() >= minWeight &&
                                    patient.weight.toInt() <= maxWeight 
                                    &&
                                    searchInDiseases (patient)
                                    ) {
                                  counts++;
                                }
                              }
                              setState(() {
                                  
                                result = (counts/patientUserList.length * 100).toInt()  ;
                              });
                          
                            },
                            child: Text('تطبيق'),
                          ),
                        ),
                      ),
                       result != null ? 
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Center(
                           child: SizedBox(
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
                    value: result/100,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$result %',

                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                ),
              )
            ],
          ),
        ),
                         ),
                       ) : Container()
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
