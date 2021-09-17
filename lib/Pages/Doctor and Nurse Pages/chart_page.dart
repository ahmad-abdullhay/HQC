import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hqc_flutter/Models/biometrics.dart';

class ChartPage extends StatefulWidget {
  final List<Biometrics> patientBiometrics;

  const ChartPage({Key key, this.patientBiometrics}) : super(key: key);

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  bool isShowingBreathing = true;
  bool isShowingTemperature = true;
  List<charts.Series<Biometrics, String>> _createRandomData() {
    return [
      charts.Series<Biometrics, String>(
        id: 'tempreature',
        domainFn: (Biometrics b, _) => b.date,
        measureFn: (Biometrics b, _) => int.parse(b.temperature),
        data: isShowingTemperature
            ? widget.patientBiometrics.reversed.toList()
            : [],
        fillColorFn: (Biometrics b, _) {
          return charts.MaterialPalette.blue.shadeDefault;
        },
      ),
      charts.Series<Biometrics, String>(
        id: 'breathing',
        domainFn: (Biometrics b, _) => b.date,
        measureFn: (Biometrics b, _) => int.parse(b.breathingRate),
        data: isShowingBreathing
            ? widget.patientBiometrics.reversed.toList()
            : [],
        fillColorFn: (Biometrics b, _) {
          return charts.MaterialPalette.teal.shadeDefault;
        },
      ),
    ];
  }

  barChart() {
    return charts.BarChart(
      _createRandomData(),
      animate: true,
      vertical: true,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.grouped,
        strokeWidthPx: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير المريض'),
      ),
      body: Column(children: [
        Flexible(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                child: Text('معدل التنفس'),
                onPressed: () {
                  setState(() {
                    isShowingBreathing = !isShowingBreathing;
                  });
                },
                color: isShowingBreathing ? Colors.teal : Colors.grey,
              ),
              FlatButton(
                child: Text('درجة الحرارة'),
                onPressed: () {
                  setState(() {
                    isShowingTemperature = !isShowingTemperature;
                  });
                },
                color: isShowingTemperature ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
        Flexible(
          flex: 9,
          child: barChart(),
        ),
      ]),
    );
  }
}
