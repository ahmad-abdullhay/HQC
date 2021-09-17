import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hqc_flutter/Models/user.dart';

class Researcher extends User {
Researcher();
  factory Researcher.fromDocument(DocumentSnapshot doc,String firebaseID ) {
    Researcher researcher = Researcher();
        researcher.id = doc['id'];
        researcher.email= doc['email'];
        researcher.name = doc['name'];
        researcher.type = doc['type'];
        researcher.firebaseID = firebaseID;
        return researcher;
  }
}