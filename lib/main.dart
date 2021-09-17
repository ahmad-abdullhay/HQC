import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Models/user.dart';
import 'Pages/login_page.dart';

void main() {
  runApp(Main());
}

class Main extends StatefulWidget {
  static User currentUser;
  static BluetoothDevice bd;
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    init();
    super.initState();
  }
String messageTitle = "Empty";
String notificationAlert = "alert";

// FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
   bool isLoading = true;
   firebaseNotification() async {
    
   }
   Future<void> init() async {
     await Firebase.initializeApp();
     setState(() {
       isLoading = false;
     });
   }
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
         theme: ThemeData(
           primaryColor: Colors.orangeAccent,
         ),
         localizationsDelegates: [
           GlobalMaterialLocalizations.delegate,
           GlobalWidgetsLocalizations.delegate,
         ],
         supportedLocales: [
           Locale("ar", "SA"),
         ],
         locale: Locale("ar", "SA"),
        home: isLoading ? Container() : LoginPage());

   }
 
 
}
