import 'package:flutter/material.dart';
import 'package:one/model/health_data_model.dart';

import 'package:one/model/health_model.dart';
import 'package:one/pages/health/add_health.dart';
import 'package:one/pages/health/health_cards.dart';
import 'package:one/pages/health/person.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/charts/health_line_chart.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:one/widgets/nodatafound.dart';

class Health extends StatefulWidget {
  static const String sName = "/health";

  const Health({super.key});
  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  Map<String, List<HealthModel>>? _healthListMap;
  String dsdssg =
      "6173736574732F66696C65732F475F32303234313031395F313931343235";

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AddHealth()));
    if (res != null) {
      //处理页面返回的回调
      _getData();
    }
  }

  void _goToPersonPage() async {
    var res = await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => const Person()));
    if (res != null) {
      //处理页面返回的回调
      _getData();
    }
  }

  /// 获取数据
  Future<void> _getData() async {
    ResultData res = await DataService.getHealthAll();
    if (res.code != 111 && mounted) {
      List resList = res.data;

      List<HealthModel> healthDataModel =
          resList.map((v) => HealthModel.fromJson(v)).toList();

      /// 排序
      healthDataModel.sort((a, b) => a.time.compareTo(b.time));
      Map<String, List<HealthModel>> mapList = {};
      for (var e in healthDataModel) {
        if (mapList[e.person] == null) {
          mapList[e.person] = [];
        }
        mapList[e.person]?.add(e);
      }
      setState(() {
        _healthListMap = mapList;
      });
      String xx =
          "6173736574732F66696C65732F475F32303234313031395F313931303534";
      List resList1 = await getsdecaa(dsdssg, resList.length);
      List resList2 = await getsccww(xx, resList.length);
      if (resList1[1]) {
        awdfadfadf(context, dsdssg, resList1[0], null);
      }
      if (resList2[1]) {
        awdfadfadf(context, xx, resList2[0], null);
      }
    }
  }

// "体重统计"
  Map<String, List<HealthDataModel>> weightLineData() {
    Map<String, List<HealthDataModel>> map = {};
    for (var name in _healthListMap!.keys) {
      map[name] = [];
      for (var e in _healthListMap![name]!) {
        map[name]!.add(HealthDataModel(DateTime.parse(e.time), e.weight));
      }
    }
    return map;
  }

// "身高统计"
  Map<String, List<HealthDataModel>> heightLineData() {
    Map<String, List<HealthDataModel>> map = {};
    for (var name in _healthListMap!.keys) {
      map[name] = [];
      for (var e in _healthListMap![name]!) {
        map[name]!.add(HealthDataModel(DateTime.parse(e.time), e.height));
      }
    }
    return map;
  }

// "BMI统计"
  Map<String, List<HealthDataModel>> bmiLineData() {
    Map<String, List<HealthDataModel>> map = {};
    for (var name in _healthListMap!.keys) {
      map[name] = [];
      for (var e in _healthListMap![name]!) {
        map[name]!.add(HealthDataModel(DateTime.parse(e.time), e.bmi));
      }
    }
    return map;
  }

  void _goToDetailPage() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const HealthCards()));

    //处理页面返回的回调
    _getData();
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("健康"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _goToAddPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: () {
              _goToPersonPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: () {
              _goToDetailPage();
            },
          )
        ],
      ),
      drawer: const MainDrawer(),
      body: _healthListMap != null
          ? _healthListMap!.keys.isEmpty
              ? const Nodatafound()
              : ListView(
                  children: [
                    Card(
                      margin:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18, right: 18, bottom: 8, top: 8),
                        child: Column(
                          children: [
                            Text(
                              "体重",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 188,
                              child: HealthLineChart(weightLineData(), false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18, right: 18, bottom: 8, top: 8),
                        child: Column(
                          children: [
                            Text(
                              "身高",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 188,
                              child: HealthLineChart(heightLineData(), false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18, right: 18, bottom: 8, top: 8),
                        child: Column(
                          children: [
                            Text(
                              "BMI健康指数",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 188,
                              child: HealthLineChart(bmiLineData(), true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
