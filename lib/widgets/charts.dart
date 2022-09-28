import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:software_security/ffi/ffi_channel.dart';

class DeveloperChart extends StatelessWidget {
  const DeveloperChart({super.key, required this.series});

  final List<charts.Series<MsgType, String>> series;

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(series, animate: true);
  }
}
