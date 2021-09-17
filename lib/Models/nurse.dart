import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hqc_flutter/Models/user.dart';

class Nurse extends User {
Nurse();
  factory Nurse.fromDocument(DocumentSnapshot doc,String firebaseID ) {
    Nurse nurse = Nurse();
        nurse.id = doc['id'];
        nurse.email= doc['email'];
        nurse.name = doc['name'];
        nurse.type = doc['type'];
        nurse.firebaseID = firebaseID;
        return nurse;
  }
}