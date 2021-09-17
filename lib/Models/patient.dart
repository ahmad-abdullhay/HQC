import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hqc_flutter/Models/biometrics.dart';
import 'package:hqc_flutter/Models/prescription.dart';
import 'package:hqc_flutter/Models/user.dart';

class Patient  extends User{
bool gender;
int age;
DateTime enterDate;
bool isPregnant;
bool isSmoker;
int weight;
List<dynamic> diseases;
List<Biometrics> biometricsList = [];
List<Prescription> prescriptionList = [];
   Patient({this.gender,this.age,this.diseases,this.enterDate,this.isPregnant,this.isSmoker,this.weight,this.biometricsList,this.prescriptionList});

  factory Patient.fromDocument(DocumentSnapshot doc,String firebaseID ) {
    Patient patient = Patient(
        age: doc['age'],
        gender: doc['gender'],
        isPregnant: doc['isPregnant'],
        isSmoker: doc['isSmoker'],
        weight: doc['weight'],
        diseases: doc['diseases'],
        enterDate: doc['enterDate'].toDate(),
        biometricsList: Biometrics.fromFirebase(doc['biometricsList'])  ?? [],
        prescriptionList: Prescription.fromFirebase(doc['prescription']) ?? []
        );
        patient.id = doc['id'];
        patient.email= doc['email'];
        patient.name = doc['name'];
        patient.type = doc['type'];
        patient.firebaseID = firebaseID;
        return patient;
  }
}