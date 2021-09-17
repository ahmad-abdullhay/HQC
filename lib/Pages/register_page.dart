import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/doctor.dart';
import 'package:hqc_flutter/Models/nurse.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Models/researcher.dart';
import 'package:hqc_flutter/Widgets/input_text_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';
import '../main.dart';
import 'Doctor and Nurse Pages/search_in_patients_page.dart';
import 'Patient Pages/patient_register_page.dart';
import 'Researcher Pages/researcher_main_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String id;
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection('users');
  String password;
  String passwordCheck;
  String email;
  String name;
  String userType;
  List<String> useres = [
    'مريض',
    'دكتور',
    'ممرض',
    'باحث',
  ];
  bool isRegistering = false;

  patientRegister() {
    Patient user = Patient();
    user.id = id;
    user.password = password;
    user.email = email;
    user.type = 'مريض';
    user.name = name;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PatientRegisterPage(
                user: user,
              )),
    );
  }

  registerUsingFirebase() async {
    setState(() {
      isRegistering = true;
    });
    var user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: '$id@HQCdumpEmails.com',
        password: password,
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
      WidgetsFlutterBinding.ensureInitialized();
      
      await userRef.doc(user.uid).set({
        "id": id,
        "email": email,
        "name": name,
        "type": userType,
        "registrationTokens" : await  FirebaseMessaging.instance.getToken(),
        "chatsList" : [],
      });

      setState(() {
        isRegistering = false;
      });
    } else {
      setState(() {
        isRegistering = false;
      });
      return;
    }
    switch (userType) {
      case 'دكتور':
        {
          Doctor doctor = Doctor();
          doctor.email = email;
          doctor.id = id;
          doctor.firebaseID = user.uid;
          doctor.name = name;
          doctor.type = userType;
          Main.currentUser = doctor;
          
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SearchInPatientsPage(
                  isDoctor: true,
                ),
              ),
              (r) => false);
          break;
        }
      case 'ممرض':
        {
          Nurse nurse = Nurse();
          nurse.email = email;
          nurse.id = id;
          nurse.firebaseID = user.uid;
          nurse.name = name;
          nurse.type = userType;
          Main.currentUser = nurse;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SearchInPatientsPage(
                  isDoctor: false,
                ),
              ),
              (r) => false);
          break;
        }
      case 'باحث':
        {
          Researcher researcher = Researcher();
          researcher.email = email;
          researcher.id = id;
          researcher.firebaseID = user.uid;
          researcher.name = name;
          researcher.type = userType;
          Main.currentUser = researcher;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ResearcherMainPage(),
              ),
              (r) => false);
          break;
        }
    }
  }

  Function idValidator = (value) {
    bool idValid = true;
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    } else if (value.length != 10) {
      return 'يجب ان يتكون الرقم من 10 ارقام';
    } else if (double.tryParse(value) == null) {
      return 'يجب ان يحتوي على ارقام فقط';
    } else if (!idValid) {
      return 'يرجى التحقق من كتابة الرقم بشكل صحيح';
    }
    return null;
  };

  Function passValidator = (value) {
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    } else if (value.length < 6) {
      return 'كلمة السر يجب ان تكون اكثر من 5 احرف';
    }

    return null;
  };

  Function emailValidator = (value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    } else if (!emailValid) {
      return 'تأكد من صياغة البريد الالكتروني بشكل صحيح';
    }
    return null;
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: isRegistering,
          child: Center(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputTextField(
                      hintText: 'الاقامة / الهوية الوطنية',
                      textInputType: TextInputType.number,
                      icon: Icon(Icons.person),
                      onChanged: (value) {
                        id = value;
                      },
                      validator: idValidator,
                    ),
                    InputTextField(
                      hintText: 'كلمة المرور',
                      textInputType: TextInputType.visiblePassword,
                      icon: Icon(Icons.security),
                      isObscure: true,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: passValidator,
                    ),
                    InputTextField(
                      hintText: 'تأكيد كلمة المرور',
                      textInputType: TextInputType.visiblePassword,
                      icon: Icon(Icons.security),
                      isObscure: true,
                      onChanged: (value) {
                        passwordCheck = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'هذا الحقل لا يمكن تركه فارغاً';
                        } else if (value != password) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    InputTextField(
                      hintText: 'البريد الالكتروني',
                      textInputType: TextInputType.emailAddress,
                      icon: Icon(Icons.email),
                      onChanged: (value) {
                        email = value;
                      },
                      validator: emailValidator,
                    ),
                    InputTextField(
                      hintText: 'الاسم الثنائي',
                      textInputType: TextInputType.name,
                      icon: Icon(Icons.text_fields),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: DropdownButton(
                        underline: SizedBox.shrink(),
                        hint: Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 4, top: 8, bottom: 8),
                          child: Text('اختر نوع الحساب'),
                        ),
                        value: userType,
                        onChanged: (newValue) {
                          setState(() {
                             FocusScope.of(context).requestFocus(FocusNode());
                            userType = newValue;
                          });
                        },
                        items: useres.map((c) {
                          return DropdownMenuItem(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 40, right: 4, top: 8, bottom: 8),
                              child: new Text(c),
                            ),
                            value: c,
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 120,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          if (!formKey.currentState.validate()) return;

                          if (userType == 'مريض') {
                            patientRegister();
                          } else {
                            registerUsingFirebase();
                          }
                        },
                        child: Text('استمرار'),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
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
