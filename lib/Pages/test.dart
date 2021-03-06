import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hqc_flutter/Models/biometrics.dart';

import '../main.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    @required BluetoothDevice device,
    int rssi,
    GestureTapCallback onTap,
    GestureLongPressCallback onLongPress,
    bool enabled = true,
  }) : super(
          onTap: onTap,
          onLongPress: onLongPress,
          enabled: enabled,
          leading:
              Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
          title: Text(device.name ?? "Unknown device"),
          subtitle: Text(device.address.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              rssi != null
                  ? Container(
                      margin: new EdgeInsets.all(8.0),
                      child: DefaultTextStyle(
                        style: _computeTextStyle(rssi),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(rssi.toString()),
                            Text('dBm'),
                          ],
                        ),
                      ),
                    )
                  : Container(width: 0, height: 0),
              device.isConnected
                  ? Icon(Icons.import_export)
                  : Container(width: 0, height: 0),
              device.isBonded
                  ? Icon(Icons.link)
                  : Container(width: 0, height: 0),
            ],
          ),
        );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symetry*/
      return TextStyle(color: Colors.redAccent);
  }
}

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
    List<String> messages = [];
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  bool isDiscovering;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        results.add(r);
      });
    });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? Text('Discovering devices')
            : Text('Discovered devices'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: Column(children: [
        Container(
                  height: MediaQuery.of(context).size.height * 0.40,

          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, index) {
              BluetoothDiscoveryResult result = results[index];
              return BluetoothDeviceListEntry(
                device: result.device,
                rssi: result.rssi,
                onTap: () {
                  Main.bd = result.device;
                  BluetoothConnection.toAddress(result.device.address)
                      .then((_connection) {
                    print('Connected to the device');

                    _connection.input.listen(_onDataReceived).onDone(() {
                      // Example: Detect which side closed the connection
                      // There should be `isDisconnecting` flag to show are we are (locally)
                      // in middle of disconnecting process, should be set before calling
                      // `dispose`, `finish` or `close`, which all causes to disconnect.
                      // If we except the disconnection, `onDone` should be fired as result.
                      // If we didn't except this (no flag set), it means closing by remote.
                    });
                  });
                },
                onLongPress: () async {
                  try {
                    bool bonded = false;
                    if (result.device.isBonded) {
                      print('Unbonding from ${result.device.address}...');
                      await FlutterBluetoothSerial.instance
                          .removeDeviceBondWithAddress(result.device.address);
                      print('Unbonding from ${result.device.address} has succed');
                    } else {
                      print('Bonding with ${result.device.address}...');
                      bonded = await FlutterBluetoothSerial.instance
                          .bondDeviceAtAddress(result.device.address);
                      print(
                          'Bonding with ${result.device.address} has ${bonded ? 'succed' : 'failed'}.');
                    }
                    setState(() {
                      results[results.indexOf(result)] = BluetoothDiscoveryResult(
                          device: BluetoothDevice(
                            name: result.device.name ?? '',
                            address: result.device.address,
                            type: result.device.type,
                            bondState: bonded
                                ? BluetoothBondState.bonded
                                : BluetoothBondState.none,
                          ),
                          rssi: result.rssi);
                    });
                  } catch (ex) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error occured while bonding'),
                          content: Text("${ex.toString()}"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
      Container(
        height: MediaQuery.of(context).size.height * 0.40,
        child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.red,
                          child: Text('${messages[index]}')),
                      );
                    }),
      ) 
      ]),
    );
  }

  Biometrics biometrics = Biometrics();
  int index = 0;
  String currentString = '';
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data);
    var list =AsciiEncoder().convert(dataString);
    if (list.contains(10)){
    setState(() {
      currentString+=dataString.substring(0,list.indexOf(10));
      messages.add(currentString);

      currentString = '';
      currentString+=dataString.substring(list.indexOf(10)+1);
    });
    } else {
      currentString+=dataString;
    }
  }
}
