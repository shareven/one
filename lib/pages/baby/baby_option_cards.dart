import 'package:flutter/material.dart';

import 'package:one/model/babyoption_model.dart';
import 'package:one/pages/baby/add_baby_option.dart';
import 'package:one/pages/baby/baby.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/leave_behind_list_item.dart';
import 'package:one/widgets/nodatafound.dart';

class BabyOptionCards extends StatefulWidget {
  const BabyOptionCards({super.key});

  @override
  State<BabyOptionCards> createState() => _BabyOptionCardsState();
}

class _BabyOptionCardsState extends State<BabyOptionCards> {
  List<BabyoptionModel>? options;

  /// 获取数据
  Future<void> _getOptions() async {
    ResultData res = await DataService.getBabyoption();
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<BabyoptionModel> opts =
          resList.map((e) => BabyoptionModel.fromJson(e)).toList();
      setState(() {
        options = opts;
      });
    }
  }

  void handleUndo(BabyoptionModel item, int insertionIndex) {
    setState(() {
      options?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(BabyoptionModel item) {
    final int insertionIndex = options!.indexOf(item);
    setState(() {
      options!.remove(item);
    });
    showDeleteDialog(
      context,
      '确定删除以下活动选项?\n\n${item.name}',
      cancelFn: () => handleUndo(item, insertionIndex),
      deleteFn: () => _delete(item, insertionIndex),
    );
  }

  void _delete(BabyoptionModel item, int insertionIndex) async {
    ResultData res = await DataService.deleteBabyoption(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据

      showErrorMsg(res.data.toString());
    }
  }

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AddBabyOption()));
    if (res != null && mounted) {
      //处理页面返回的回调
      _getOptions();
    }
  }

  @override
  void initState() {
    _getOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (options == null) {
      mainWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (options!.isEmpty) {
      mainWidget = const Nodatafound();
    } else {
      mainWidget = ListView(
        children: options!
            .map((item) => LeaveBehindListItem(
                  dismissibleKey: ObjectKey(item),
                  titleText: item.name,
                  subtitle: Text(item.updatedAt),
                  onDelete: () => _handleDelete(item),
                ))
            .toList(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.popAndPushNamed(
                  context,
                  Baby.sName,
                )),
        title: const Text("宝贝活动选项"),
      ),
      body: RefreshIndicator(
        onRefresh: _getOptions,
        child: mainWidget,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
