import 'package:flutter/material.dart';

import 'package:one/model/cost_type_model.dart';
import 'package:one/pages/accounts/add_const_type.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/leave_behind_list_item.dart';
import 'package:one/widgets/nodatafound.dart';

class CostType extends StatefulWidget {
  const CostType({super.key});

  @override
  State<CostType> createState() => _CostTypeState();
}

class _CostTypeState extends State<CostType> {
  List<CostTypeModel>? _costTypeList;

  /// 获取数据
  Future<void> _getCostTypes() async {
    ResultData res = await DataService.getCostType();
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<CostTypeModel> costTypeData =
          resList.map((e) => CostTypeModel.fromJson(e)).toList();
      costTypeData.sort(
        (a, b) => b.isIncome.toString().length - a.isIncome.toString().length,
      );
      setState(() {
        _costTypeList = costTypeData;
      });
    }
  }

  void handleUndo(CostTypeModel item, int insertionIndex) {
    setState(() {
      _costTypeList?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(CostTypeModel item) {
    final int insertionIndex = _costTypeList!.indexOf(item);
    setState(() {
      _costTypeList!.remove(item);
    });
    showDeleteDialog(
      context,
      '确定删除以下分类?\n\n${item.name}',
      cancelFn: () => handleUndo(item, insertionIndex),
      deleteFn: () => _delete(item, insertionIndex),
    );
  }

  void _delete(CostTypeModel item, int insertionIndex) async {
    ResultData res = await DataService.deleteCostType(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据

      showErrorMsg(res.data.toString());
    }
  }

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AddCostType()));
    if (res != null && mounted) {
      //处理页面返回的回调
      _getCostTypes();
    }
  }

  @override
  void initState() {
    _getCostTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (_costTypeList == null) {
      mainWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_costTypeList!.isEmpty) {
      mainWidget = const Nodatafound();
    } else {
      mainWidget = ListView(
        children: _costTypeList!
            .map(
              (item) => LeaveBehindListItem(
                dismissibleKey: ObjectKey(item),
                titleText: item.name,
                subtitle: Text(
                  item.isIncome ? "收入" : "支出",
                  style: TextStyle(
                      fontSize: 14,
                      color: item.isIncome
                          ? Colors.green
                          : Theme.of(context).hintColor),
                ),
                onDelete: () => _handleDelete(item),
              ),
            )
            .toList(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("分类"),
      ),
      body: RefreshIndicator(
        onRefresh: _getCostTypes,
        child: mainWidget,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
