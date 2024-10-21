import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:one/model/baby_model.dart';
import 'package:one/model/babyoption_model.dart';
import 'package:one/pages/baby/baby_option_cards.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:one/widgets/nodatafound.dart';

class Baby extends StatefulWidget {
  static const String sName = "/baby";

  const Baby({super.key});
  @override
  State<Baby> createState() => _BabyState();
}

class _BabyState extends State<Baby> with SingleTickerProviderStateMixin {
  Map<String, List<BabyModel>>? mapOptionList;
  List<BabyModel>? baByListData;
  TabController? _tabController;
  List<BabyoptionModel>? options;

  void _goToOptionPage() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const BabyOptionCards()));
  }

  /// 获取数据
  Future<void> _getOptions() async {
    ResultData res = await DataService.getBabyoption();

    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<BabyoptionModel> opts =
          resList.map((e) => BabyoptionModel.fromJson(e)).toList();
      setState(() {
        options = opts;
        _tabController = TabController(length: opts.length, vsync: this);
      });
    }
  }

  Future<void> _getData() async {
    if (options == null) return;
    ResultData res = await DataService.getBaby();
    if (res.code != 111 && mounted) {
      List resList = res.data;

      List<BabyModel> babyData =
          resList.map((v) => BabyModel.fromJson(v)).toList();

      /// 排序
      // babyData.sort((a, b) => a.startTime.compareTo(b.startTime));

      Map<String, List<BabyModel>> mapData = {};
      for (var option in options!) {
        mapData[option.name] = [];
        for (var e in babyData) {
          if (option.name == e.option) {
            mapData[option.name]?.add(e);
          }
        }
      }
      setState(() {
        baByListData = babyData;
        mapOptionList = mapData;
      });
    }
  }

  /// 开始
  void start(String option) async {
    Loading.showLoading(context);
    Map<String,dynamic> data = {
      "option": option,
      "startTime": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())
    };
    ResultData res = await DataService.addBaby(data);
    if (res.code != 111) {
      await _getData();
    }
    if (mounted) Loading.hideLoading(context);
  }

  /// 结束
  void end(String option) async {
    if (baByListData == null) return;
    Loading.showLoading(context);
    var id = baByListData!.firstWhere((e) => e.option == option).id;
    Map<String,dynamic> data = {
      "endTime": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())
    };
    ResultData res = await DataService.putBaby(id, data);
    if (res.code != 111) {
      await _getData();
    }
    if (mounted) Loading.hideLoading(context);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  _init() async {
    await _getOptions();
    _getData();
  }

  /// 计算持续时间长
  String _computeTimeDuration(String startTime, String endTime) {
    Duration duration =
        DateTime.parse(endTime).difference(DateTime.parse(startTime));
    return duration.toString().replaceAll(".000000", "");
  }

  _showConfirm(BabyModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定删除以下这条记录吗?\n\n${item.startTime}\n${item.endTime ?? ""}',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("取消", style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("删除", style: TextStyle(color: Colors.pink)),
            onPressed: () {
              _delete(item.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _delete(id) async {
    Loading.showLoading(context);
    ResultData res = await DataService.deleteBaby(id);
    if (res.code != 111) {
      await _getData();
    }
    if (mounted) Loading.hideLoading(context);
  }

  Widget buildItem(BuildContext context, String option) {
    bool disableEnd = true;

    List<BabyModel>? list = mapOptionList?[option];
    if (list != null && list.isNotEmpty) {
      String? endTime = list[0].endTime;
      disableEnd = endTime != null && endTime.isNotEmpty;
    }

    /// Map<Time,List>
    Map<String, List<BabyModel>> map = <String, List<BabyModel>>{};
    list?.forEach((x) {
      List ll = x.startTime.split(" ");
      String day = ll[0];
      if (map[day] == null) {
        map[day] = [];
      }
      map[day]?.add(x);
    });

    if (list == null) return Container();
    return RefreshIndicator(
      onRefresh: _getData,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).secondaryHeaderColor,
              child: list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(38.0),
                      child: Nodatafound(),
                    )
                  : ListView(
                      children: map.keys
                          .map((e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      e,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  Column(
                                    children: map[e]!
                                        .map((x) => InkWell(
                                              onLongPress: () =>
                                                  _showConfirm(x),
                                              child: Container(
                                                color:
                                                    Theme.of(context).cardColor,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(x.startTime
                                                        .substring(10)),
                                                    Text(x.endTime != null
                                                        ? x.endTime!
                                                            .substring(10)
                                                        : ''),
                                                    Text(x.endTime != null
                                                        ? _computeTimeDuration(
                                                            x.startTime,
                                                            x.endTime!)
                                                        : ''),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                ],
                              ))
                          .toList(),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  child: Container(
                      height: 200,
                      color: Colors.teal,
                      child: const Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Start",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ))),
                  onTap: () => start(option),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: disableEnd ? null : () => end(option),
                  child: Container(
                    height: 200,
                    color: disableEnd ? Colors.grey : Colors.purple,
                    child: const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 5),
                        Text("End",
                            style:
                                TextStyle(color: Colors.white, fontSize: 24)),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (baByListData == null || options == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (options!.isEmpty) {
      body = const Nodatafound();
    } else {
      body = TabBarView(
        controller: _tabController,
        children: options!.map((e) => buildItem(context, e.name)).toList(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("宝贝"),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_activity_rounded),
            onPressed: () {
              _goToOptionPage();
            },
          ),
        ],
        bottom: options != null
            ? TabBar(
                controller: _tabController,
                tabs: options!.map((v) => Tab(text: v.name)).toList(),
              )
            : null,
      ),
      drawer: const MainDrawer(),
      body: body,
    );
  }
}
