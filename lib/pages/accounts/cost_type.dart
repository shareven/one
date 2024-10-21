import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:one/model/cost_type_model.dart';
import 'package:one/pages/accounts/add_const_type.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/nodatafound.dart';

class CostType extends StatefulWidget {
  const CostType({super.key});

  @override
  State<CostType> createState() => _CostTypeState();
}

class _CostTypeState extends State<CostType> {
  List<CostTypeModel>? _costTypeList;
  final DismissDirection _dismissDirection = DismissDirection.endToStart;

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
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定删除以下分类?\n\n${item.name}',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
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
              _delete(item, insertionIndex);
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
      setState(() {
        _costTypeList!.add(CostTypeModel.fromJson(res));
      });
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
            .map((item) => _LeaveBehindListItem(
                dismissDirection: _dismissDirection,
                item: item,
                onTap: (v) {},
                onDelete: _handleDelete))
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

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    required this.item,
    required this.onDelete,
    required this.onTap,
    required this.dismissDirection,
  });

  final CostTypeModel item;
  final DismissDirection dismissDirection;
  final void Function(CostTypeModel) onDelete;
  final void Function(CostTypeModel) onTap;

  void _handleDelete() {
    onDelete(item);
  }

  void _handleTap() {
    onTap(item);
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
        child: Card(
          child: Container(
            decoration: BoxDecoration(
                color: theme.canvasColor,
                border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: ListTile(
              onTap: _handleTap,
              title: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.isIncome ? "收入" : "支出",
                style: TextStyle(
                    fontSize: 14,
                    color: item.isIncome ? Colors.green : theme.hintColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
