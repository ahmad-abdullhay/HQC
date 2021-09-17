import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hqc_flutter/Models/biometrics.dart';
import 'package:hqc_flutter/Models/patient.dart';
import 'package:hqc_flutter/Pages/Patient%20Pages/biometrics_page.dart';
import 'package:toast/toast.dart';

class BiometricsMesurementPage extends StatefulWidget {
  final Patient patient;

  const BiometricsMesurementPage({Key key, this.patient}) : super(key: key);
  @override
  _BiometricsMesurementPageState createState() =>
      _BiometricsMesurementPageState();
}

class _BiometricsMesurementPageState extends State<BiometricsMesurementPage> {
  @override
  void initState() {
   //  _startDiscovery();
    temp();
    super.initState();
  }

  temp() async {
    await Future.delayed(Duration(seconds: 5));
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => BiometricsPage(
                patient: widget.patient,
                    biometrics: Biometrics(
                        breathingRate: Random().nextInt(50).toString(),
                        temperature: Random().nextInt(50).toString(),
              date: '1')),
                  ));
  
  }

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        results.add(r);
      });
    });

    _streamSubscription.onDone(() {
      for (BluetoothDiscoveryResult bluetoothDiscoveryResult in results) {
        if (bluetoothDiscoveryResult.device.name == 'HC-06') {
          connectToBluetoothDevice(bluetoothDiscoveryResult.device);
          Toast.show('find the device', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          break;
        }
      }
    });
  }

  void connectToBluetoothDevice(BluetoothDevice bluetoothDevice) {
    BluetoothConnection.toAddress(bluetoothDevice.address).then((_connection) {
      Toast.show('Connected', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print('Connected to the device');
      _connection.input.listen(_onDataReceived).onDone(() {});
    });
  }

  int index = 0;
  String currentString = '';
  List<String> messages = [];
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data);
    var list = AsciiEncoder().convert(dataString);
    if (list.contains(10)) {
      currentString += dataString.substring(0, list.indexOf(10));
      messages.add(currentString.substring(2));
      Toast.show(currentString, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      currentString = '';
      currentString += dataString.substring(list.indexOf(10) + 1);
    } else {
      currentString += dataString;
    }
    if (messages.length == 2) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => BiometricsPage(
                    biometrics: Biometrics(
                        breathingRate: messages.first,
                        temperature: messages.last),
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطوات قياس العلامات الحيوية'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('تشغيل البلوتوث وربطه بالجهاز'),
                    ),
                    StepsProgressIndicator(
                      stepNumber: 1,
                      stepText: 'الخطوة الأولى',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StepsProgressIndicator(
                      stepNumber: 2,
                      stepText: 'الخطوة الثانية',
                    ),
                    Text('ضع الجهاز في الفم لمدة دقيقة \nكما في الصورة'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child:
                          Text('انتظر قليلاً... \nستظهر نتائج علاماتك الحيوية'),
                    ),
                    StepsProgressIndicator(
                      stepNumber: 3,
                      stepText: 'الخطوة الثالثة',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepsProgressIndicator extends StatelessWidget {
  final int stepNumber;
  final String stepText;

  const StepsProgressIndicator({Key key, this.stepNumber, this.stepText})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                value: stepNumber / 3,
                valueColor: AlwaysStoppedAnimation(Colors.green),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          Center(
            child: Text(
              stepText,
              style: TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
