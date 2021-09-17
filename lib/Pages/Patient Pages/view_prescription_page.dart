import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Models/prescription.dart';

class ViewPrescriptionPage extends StatefulWidget {
  final Patient patient;

  const ViewPrescriptionPage({Key key,this.patient}) : super(key: key);
  @override
  _ViewPrescriptionPageState createState() => _ViewPrescriptionPageState();
}

int _currentIndex = 0;

class _ViewPrescriptionPageState extends State<ViewPrescriptionPage> {
  bool isLoading = true;
  @override
  void initState() {
    
    readPrescription();
      super.initState();
  }
  readPrescription() async {

     DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.patient.firebaseID).get();
     widget.patient.prescriptionList = Prescription.fromFirebase(doc['prescription']);
    setState(() {
      isLoading = false;
    });
  }
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    _currentIndex = result.length - 1;
    return result;
  }
  
  int index = 0;
  @override
  Widget build(BuildContext context) {
    index = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('الوصفة الطبية'),
      ),
      body:!isLoading ? SafeArea(
        child: widget.patient.prescriptionList != null
            ? Column(children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.77,
                    onPageChanged: (index, reason) {
                      print(index);
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: widget.patient.prescriptionList.map((card) {
                    return Builder(builder: (BuildContext context) {
                      return PrescriptionCard(
                        prescription: card,
                        index: index++,
                      );
                    });
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: map<Widget>(widget.patient.prescriptionList, (index, url) {
                    return Container(
                      width: 10.0,
                      height: 10.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ])
            : Center(
                child: Container(
                child: Text('لا يوجد وصفة طبية بعد'),
              )),
      ) :Center(child: CircularProgressIndicator()),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final int index;
  const PrescriptionCard({
    Key key,
    @required this.prescription,
    this.index,
  }) : super(key: key);

  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'اسم الدواء',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 24),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Text(
                  prescription.name,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Center(
              child: Text(
                'المدة المعنية لأخذ الدواء',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 24),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Text(
                  prescription.period,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Center(
              child: Text(
                'الكمية المطلوبة',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 24),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Text(
                  prescription.amount,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Center(
              child: Text(
                'ملاحظات اضافية',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 24),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Text(
                  prescription.notes,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
