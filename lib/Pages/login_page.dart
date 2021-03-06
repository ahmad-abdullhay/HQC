import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/doctor.dart';
import 'package:hqc_flutter/Models/nurse.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Models/researcher.dart';
import 'package:hqc_flutter/Pages/Researcher%20Pages/researcher_main_page.dart';
import 'package:hqc_flutter/Pages/register_page.dart';
import 'package:hqc_flutter/Widgets/input_text_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';
import '../main.dart';
import 'Doctor and Nurse Pages/search_in_patients_page.dart';
import 'Patient Pages/patient_main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection('users');
  String id;
  String password;

  Future loginUsingFirebase() async {
    setState(() {
      isLogin = true;
    });
    var user;
    try {
      final status = (await _auth.signInWithEmailAndPassword(
        email: "$id@HQCdumpEmails.com",
        password: password,
      ));
      user = status.user;
    } catch (ex) {
      String errorString;
      switch (ex.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorString = "User Not Found";
          break;
        case 'The password is invalid or the user does not have a password.':
          errorString = "Password Not Valid";
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorString = "Network Error";
          break;
        default:
          {
            print('Case ${ex.message} is not jet implemented');

            errorString = "Nnkown error";
          }
      }

      Toast.show(errorString, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

      user = null;
    }
    if (user != null) {
      DocumentSnapshot doc = await userRef.doc(user.uid).get();
      switch (doc['type']) {
        case '????????':
          {
            patientLogin(doc, user);
            break;
          }
        case '????????':
          {
            nurseLogin(doc, user);
            break;
          }
        case '??????????':
          {
            doctorLogin(doc, user);
            break;
          }
        case '????????':
          {
            researcherLogin(doc, user);
            break;
          }
      }
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  patientLogin(DocumentSnapshot doc, User user) {
    Patient patient = Patient.fromDocument(doc, user.uid);
    Main.currentUser = patient;
    setState(() {
      isLogin = false;
    });
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => PatientMainPage(
            patient: patient,
          ),
        ),
        (r) => false);
  }

  nurseLogin(DocumentSnapshot doc, User user) {
    Nurse nurse = Nurse.fromDocument(doc, user.uid);
    setState(() {
      isLogin = false;
    });
    Main.currentUser = nurse;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SearchInPatientsPage(
            isDoctor: false,
          ),
        ),
        (r) => false);
  }

  researcherLogin(DocumentSnapshot doc, User user) {
    Researcher researcher = Researcher.fromDocument(doc, user.uid);
    setState(() {
      isLogin = false;
    });
    Main.currentUser = researcher;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ResearcherMainPage(),
        ),
        (r) => false);
  }

  doctorLogin(DocumentSnapshot doc, User user) {
    Doctor doctor = Doctor.fromDocument(doc, user.uid);
    setState(() {
      isLogin = false;
    });
    Main.currentUser = doctor;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SearchInPatientsPage(
            isDoctor: true,
          ),
        ),
        (r) => false);
  }

  bool isLogin = false;
  Function idValidator = (value) {
    bool idValid = true;
    if (value.isEmpty) {
      return '?????? ?????????? ???? ???????? ???????? ????????????';
    } else if (value.length != 10) {
      return '?????? ???? ?????????? ?????????? ???? 10 ??????????';
    } else if (double.tryParse(value) == null) {
      return '?????? ???? ?????????? ?????? ?????????? ??????';
    } else if (!idValid) {
      return '???????? ???????????? ???? ?????????? ?????????? ???????? ????????';
    }
    return null;
  };

  Function passValidator = (value) {
    if (value.isEmpty) {
      return '?????? ?????????? ???? ???????? ???????? ????????????';
    } else if (value.length < 6) {
      return 'Password must be more than 5 characters';
    }
    return null;
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: isLogin,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset(
                        "assets/images/logo.png",
                      ),
                      height: 100,
                      width: 200,
                      alignment: Alignment.center,
                    ),
                    InputTextField(
                      hintText: '?????????????? / ???????????? ??????????????',
                      icon: Icon(Icons.person),
                      textInputType: TextInputType.number,
                      onChanged: (value) {
                        id = value;
                      },
                      validator: idValidator,
                    ),
                    InputTextField(
                      hintText: '???????? ????????????',
                      textInputType: TextInputType.visiblePassword,
                      icon: Icon(Icons.security),
                      isObscure: true,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: passValidator,
                    ),
                    Container(
                      width: 140,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (!formKey.currentState.validate()) return;
                          loginUsingFirebase();
                        },
                        child: Text('?????????? ????????????'),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 140,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text('?????????? ???????? ????????'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
