import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:one/pages/accounts/accounts_chart.dart';

class AccountPieCharts extends StatelessWidget {
  final List<CostTypeMoney> chartData;

  const AccountPieCharts({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
        legend: const Legend(
            isVisible: true,
            // Legend will be placed at the left
            position: LegendPosition.right),
        series: <CircularSeries>[
          // Render pie chart
          PieSeries<CostTypeMoney, String>(
            dataSource: chartData,
            xValueMapper: (CostTypeMoney data, _) =>
                '${data.type}  ${NumberFormat.simpleCurrency(name: "CNY").format(data.money)}',
            yValueMapper: (CostTypeMoney data, _) => data.money,
            animationDuration: 500,
          )
        ]);
  }
}
