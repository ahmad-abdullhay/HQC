import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:toast/toast.dart';
import 'doctor_main_page.dart';
import 'nurse_main_page.dart';

class SearchInPatientsPage extends StatefulWidget {
  final bool isDoctor;

  const SearchInPatientsPage({Key key, @required this.isDoctor})
      : super(key: key);

  @override
  _SearchInPatientsPageState createState() => _SearchInPatientsPageState();
}

class _SearchInPatientsPageState extends State<SearchInPatientsPage> {
  TextEditingController textController = TextEditingController();
  bool isLoading = false;
  List<Patient> patientUserList = [];
  List<Patient> resultList = [];
  bool showErrorMessage = false;
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

  search(String value) {
    for (Patient patient in patientUserList) {
      if (patient.id == value && !resultList.contains(patient)){
  resultList.add(patient);
      setState(() {});
      return;
      }
      
    }
    if (value.length == 10 &&!resultList.contains(value)){
     
 Toast.show('لا يوجد مريض بهذا الرقم', context,
          gravity: Toast.CENTER);
    }
     
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ابحث بالمرضى'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (!isLoading) getPatientList();
            },
          )
        ],
      ),
      body: isLoading
          ? Container()
          : SafeArea(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        search(value);
                      },
                      decoration: InputDecoration(
                          hintText: 'البحث عن المريض\n باستخدام رقم الهوية',
                          hintMaxLines: 2,
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  resultList.clear();
                                  textController.clear();
                                });
                              },
                              child: Icon(Icons.clear)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28))),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    height: 400,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: resultList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (widget.isDoctor) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              DoctorMainPage(
                                                patient: resultList[index],
                                              )));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              NurseMainPage(
                                                patient: resultList[index],
                                              )));
                                }
                              },
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16.0, top: 6),
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        Text('اسم المريض: '),
                                        Text(resultList[index].name),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('رقم الهوية: '),
                                        Text(resultList[index].id),
                                      ],
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            )),
    );
  }
}
