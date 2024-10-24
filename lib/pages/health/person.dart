import 'package:flutter/material.dart';

import 'package:one/model/person_model.dart';
import 'package:one/pages/health/add_person.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/leave_behind_list_item.dart';
import 'package:one/widgets/nodatafound.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  List<PersonModel>? person;

  /// 获取数据
  Future<void> _getPersons() async {
    ResultData res = await DataService.getPerson();
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<PersonModel> personData =
          resList.map((e) => PersonModel.fromJson(e)).toList();
      setState(() {
        person = personData;
      });
    }
  }

  void handleUndo(PersonModel item, int insertionIndex) {
    setState(() {
      person?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(PersonModel item) {
    final int insertionIndex = person!.indexOf(item);
    setState(() {
      person!.remove(item);
    });
    showDeleteDialog(
      context,
      '确定删除以下人员?\n\n${item.name}',
      cancelFn: () => handleUndo(item, insertionIndex),
      deleteFn: () => _delete(item, insertionIndex),
    );
  }

  void _delete(PersonModel item, int insertionIndex) async {
    ResultData res = await DataService.deletePerson(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据

      showErrorMsg(res.data.toString());
    }
  }

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const AddPerson()));
    if (res != null && mounted) {
      //处理页面返回的回调
      setState(() {
        person!.add(PersonModel.fromJson(res));
      });
    }
  }

  @override
  void initState() {
    _getPersons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (person == null) {
      mainWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (person!.isEmpty) {
      mainWidget = const Nodatafound();
    } else {
      mainWidget = ListView(
        children: person!
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
        title: const Text("人员"),
      ),
      body: RefreshIndicator(
        onRefresh: _getPersons,
        child: mainWidget,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
