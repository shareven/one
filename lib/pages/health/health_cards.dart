import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:one/model/Health_model.dart';
import 'package:one/utils/data_service.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/nodatafound.dart';

class HealthCards extends StatefulWidget {
  static const String sName = "/healthCards";

  const HealthCards({super.key});
  @override
  State<HealthCards> createState() => _HealthCardsState();
}

class _HealthCardsState extends State<HealthCards> {
  final DismissDirection _dismissDirection = DismissDirection.endToStart;
  List<HealthModel>? _healthList;
  RefreshController? _refreshController;
  int? _countHealth;
  int _skipNum = 0;
  final int _limitNum = 10; //每次获取数量
  @override
  void initState() {
    //
    _getHealthDataModel();
    _getHealthCountData();
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    super.dispose();
  }

  // 获取总数量
  void _getHealthCountData() async {
    var res = await DataService.getHealthCount();
    if (res.code != 111 && mounted) {
      setState(() {
        _countHealth = res.data["count"];
      });
    }
  }

  Future<void> _getHealthDataModel() async {
    ResultData res = await DataService.getHealthFilter(_skipNum, _limitNum);
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<HealthModel> healthDataModel = resList.map((v) {
        return HealthModel.fromJson(v);
      }).toList();
      _healthList = _healthList ?? [];
      List<HealthModel> newList = _healthList! + healthDataModel;
      setState(() {
        _healthList = newList;
      });
    }
  }

  void _handleRefresh() async {
    if (_countHealth == null) return;
    int newSkip = _skipNum + _limitNum;
    if (newSkip <= _countHealth!) {
      setState(() {
        _skipNum = newSkip;
      });
      await _getHealthDataModel();
      _refreshController?.loadComplete();
    } else {
      _refreshController?.loadNoData();
    }
  }

  void _onLoading() async {
    if (_countHealth == null) return;
    int newSkip = _skipNum + _limitNum;
    if (newSkip <= _countHealth!) {
      setState(() {
        _skipNum = newSkip;
      });
      await _getHealthDataModel();
      _refreshController?.loadComplete();
    } else {
      _refreshController?.loadNoData();
    }
  }

  void handleUndo(HealthModel item, int insertionIndex) {
    setState(() {
      _healthList?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(HealthModel item) {
    final int insertionIndex = _healthList!.indexOf(item);
    setState(() {
      _healthList!.remove(item);
    });
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text(
                  "确定删除以下信息?\n\n\"${item.time}, ${item.person}, 体重:${item.weight}, 身高:${item.height}\""),
              actions: <Widget>[
                TextButton(
                  child: const Text("取消", style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    handleUndo(item, insertionIndex);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("删除", style: TextStyle(color: Colors.pink)),
                  onPressed: () {
                    _deleteHealth(item, insertionIndex);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  void _deleteHealth(HealthModel item, int insertionIndex) async {
    ResultData res = await DataService.deleteHealth(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据
      showErrorMsg(res.data.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_healthList == null || _refreshController == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_healthList!.isEmpty) {
      body = const Nodatafound();
    } else {
      body = SmartRefresher(
        enablePullUp: true,
        enablePullDown: false,
        controller: _refreshController!,
        onLoading: _onLoading,
        onRefresh: _handleRefresh,
        child: ListView(
          children: _healthList!.map<Widget>((HealthModel item) {
            return _LeaveBehindListItem(
                dismissDirection: _dismissDirection,
                item: item,
                onDelete: _handleDelete);
          }).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("健康信息列表"),
      ),
      body: body,
    );
  }
}

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    required this.item,
    required this.onDelete,
    required this.dismissDirection,
  });

  final HealthModel item;
  final DismissDirection dismissDirection;
  final void Function(HealthModel) onDelete;

  void _handleDelete() {
    onDelete(item);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        const CustomSemanticsAction(label: '删除'): _handleDelete,
      },
      child: Dismissible(
        key: ObjectKey(item),
        direction: dismissDirection,
        onDismissed: (DismissDirection direction) {
          _handleDelete();
        },
        background: Container(
            color: theme.primaryColor,
            child: const ListTile(
                trailing: Icon(Icons.add, color: Colors.white, size: 36.0))),
        secondaryBackground: Container(
            color: Colors.pink,
            child: const ListTile(
                contentPadding: EdgeInsets.all(14.0),
                trailing: Icon(Icons.delete, color: Colors.white, size: 36.0))),
        child: Container(
          decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: ListTile(
              title: Text(item.person),
              subtitle: Text("体重：${item.weight}\n身高：${item.height}"),
              trailing: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("BMI：${item.bmi}\n${item.time}")),
              isThreeLine: true),
        ),
      ),
    );
  }
}
