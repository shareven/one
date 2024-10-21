import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:one/model/health_data_model.dart';

class HealthLineChart extends StatelessWidget {
  final Map<String, List<HealthDataModel>> seriesList;

  final bool showRange;

  const HealthLineChart(this.seriesList, this.showRange, {super.key});

  @override
  Widget build(BuildContext context) {
    List<CartesianSeries> dataWidget = [];
    if (showRange) {
      String keyName = seriesList.keys.first;
      dataWidget.add(RangeAreaSeries<HealthDataModel, DateTime>(
        dataSource: seriesList[keyName],
        name: "正常",
        color: const Color.fromARGB(77, 138, 212, 162),
        borderDrawMode: RangeAreaBorderMode.excludeSides,
        borderWidth: 2,
        xValueMapper: (HealthDataModel data, _) => data.time,
        lowValueMapper: (HealthDataModel data, _) => 18.5,
        highValueMapper: (HealthDataModel data, _) => 25,
        animationDuration: 100,
      ));
    }
    seriesList.keys
        .map(
          (e) => dataWidget.add(LineSeries<HealthDataModel, DateTime>(
            dataSource: seriesList[e],
            name: e,
            xValueMapper: (HealthDataModel data, _) => data.time,
            yValueMapper: (HealthDataModel data, _) => data.value,
            animationDuration: 500,
          )),
        )
        .toList();

    return SfCartesianChart(
        primaryXAxis: const DateTimeAxis(),
        legend: const Legend(isVisible: true, position: LegendPosition.top),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (data, point, series, pointIndex, seriesIndex) =>
              showRange && seriesIndex < 1
                  ? Container()
                  : Container(
                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                      width: 100.0,
                      height: 45.0,
                      child: Column(
                        children: <Widget>[
                          Text(
                            DateFormat("yyyy-MM-dd").format(point.x),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "${seriesList.keys.toList()[showRange ? seriesIndex - 1 : seriesIndex]}: ${point.y}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
        ),
        series: dataWidget);
  }
}
