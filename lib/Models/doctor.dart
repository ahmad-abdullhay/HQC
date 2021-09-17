import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hqc_flutter/Models/user.dart';

class Doctor extends User {
  Doctor ();
  factory Doctor.fromDocument(DocumentSnapshot doc,String firebaseID ) {
    Doctor doctor = Doctor();
        doctor.id = doc['id'];
        doctor.email= doc['email'];
        doctor.name = doc['name'];
        doctor.type = doc['type'];
        doctor.firebaseID = firebaseID;
        return doctor;
  }
}