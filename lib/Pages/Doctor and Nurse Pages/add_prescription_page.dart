import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Models/prescription.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class AddPrescriptionPage extends StatefulWidget {
  final Patient patient;

  const AddPrescriptionPage({Key key, this.patient}) : super(key: key);
  @override
  _AddPrescriptionPageState createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  final formKey = GlobalKey<FormState>();
  final userRef = FirebaseFirestore.instance.collection('users');
  String name;
  String period;
  String amount;
  String notes;
  Function validate = (value) {
    if (value.isEmpty) {
      return 'هذا الحقل لا يمكن تركه فارغاً';
    }
    return null;
  };
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('انشاء وصفة طبية'),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'اسم الدواء',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextFormField(
                       validator: validate,
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24))),
                    ),
                  ),
                  Text(
                    'المدة المعنية لأخذ الدواء',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextFormField(
                       validator: validate,
                      onChanged: (value) {
                        period = value;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24))),
                    ),
                  ),
                  Text(
                    'الكمية المطلوبة',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextFormField(
                      validator: validate,
                      onChanged: (value) {
                        amount = value;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24))),
                    ),
                  ),
                  Text('ملاحظات اضافية'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextField(
                      onChanged: (value) {
                        notes = value;
                      },
                      decoration:
                          InputDecoration(border: OutlineInputBorder()),
                      maxLines: 4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 180,
                      height: 40,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                           if (!formKey.currentState.validate()) return;
                          widget.patient.prescriptionList.add(Prescription(
                              name: name ?? 'لم يتم تحديد الاسم',
                              amount: amount ?? 'لم يتم تحديد الكمية',
                              period: period ?? 'لم يتم تحديد المدة',
                              notes: notes ?? 'لا يوجد ملاحظات'));
                          setState(() {
                            isLoading = true;
                          });
                          await userRef.doc(widget.patient.firebaseID).set({
                            "prescription": Prescription.toFirebase(
                                widget.patient.prescriptionList),
                          }, SetOptions(merge: true));
                          setState(() {
                            isLoading = false;
                          });
                          Toast.show('تم ارسال الوصفة للمريض', context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM);
                          Navigator.pop(context);
                        },
                        child: Text('ارسال الوصفة الطبية'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
