import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:one/pages/accounts/accounts_chart.dart';

class AccountLineChart extends StatelessWidget {
  final List<TimeSeriesMoney> charData;

  const AccountLineChart({super.key, required this.charData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        // Initialize category axis
        primaryXAxis: const DateTimeAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compactSimpleCurrency(name: "CNY"),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (data, point, series, pointIndex, seriesIndex) => Container(
            color: const Color.fromRGBO(0, 0, 0, 0.3),
            width: 100.0,
            height: 40.0,
            child: Column(
              children: <Widget>[
                Text(
                  DateFormat("yyyy-MM-dd").format(point.x),
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  NumberFormat.simpleCurrency(name: "CNY", decimalDigits: 0)
                      .format(point.y),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        series: <CartesianSeries>[
          // Initialize line series
          LineSeries<TimeSeriesMoney, DateTime>(
            dataSource: charData,
            xValueMapper: (TimeSeriesMoney data, _) => data.time,
            yValueMapper: (TimeSeriesMoney data, _) => data.money,
            animationDuration: 500,
          ),
        ]);
  }
}
