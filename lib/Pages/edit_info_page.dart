import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as a;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class EditInfoPage extends StatefulWidget {
  final User user;

  const EditInfoPage({Key key, this.user}) : super(key: key);
  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final a.FirebaseAuth _auth = a.FirebaseAuth.instance;

  final userRef = FirebaseFirestore.instance.collection('users');
  String password;
  String email;
  String name;

  bool isRegistering = false;

  String passValidator(value) {
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    } else if (value.length < 6) {
      return 'كلمة السر يجب ان تكون اكثر من 5 احرف';
    }

    return null;
  }

  String emailValidator(value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    } else if (!emailValid) {
      return 'تأكد من صياغة البريد الالكتروني بشكل صحيح';
    }
    return null;
  }

  Future<void> changePassword() async {
    await _auth.currentUser.updatePassword(password);
    Toast.show('تم تغيير كلمة المرور بنجاح', context);
    password = null;
  }

  changeEmail() async {
  await  userRef
        .doc(widget.user.firebaseID)
        .set({'email': email}, SetOptions(merge: true));
        Toast.show('تم تغيير البريد الاليكتروني بنجاح', context);
             widget.user.email = email;
             email = null;

  }

  changeName() async {
   await   userRef
        .doc(widget.user.firebaseID)
        .set({'name': name}, SetOptions(merge: true));
        Toast.show('تم تغيير الاسم بنجاح', context);
     widget.user.name = name;
     name = null;
          }
          
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل المعلومات'),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: isRegistering,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      style: TextStyle(fontFamily: 'Scholar', fontSize: 16.0),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: widget.user.email,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(
                          labelText: 'تغيير البريد الاليكتروني',
                          icon: Icon(Icons.email)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      style: TextStyle(fontFamily: 'Scholar', fontSize: 16.0),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.name,
                      initialValue: widget.user.name,
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: InputDecoration(
                          labelText: 'تغيير الاسم',
                          icon: Icon(Icons.text_fields)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      style: TextStyle(fontFamily: 'Scholar', fontSize: 16.0),
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                          labelText: 'تغيير كلمة المرور',
                          icon: Icon(Icons.security)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    width: 100,
                    height: 50,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        if (name != null) {
                          await changeName();
                        }
                        if (email != null) {
                          var validate = emailValidator(email);
                          if (validate != null) {
                            Toast.show(validate, context);
                            return;
                          } else {
                            await changeEmail();
                          }
                        }
                        if (password != null) {
                          var validate = passValidator(password);
                          if (validate != null) {
                            Toast.show(validate, context);
                            return;
                          } else {
                            await changePassword();
                          }
                        }
                      },
                      child: Text('تغيير '),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
