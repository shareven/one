import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:one/model/person_model.dart';
import 'package:one/pages/health/add_person.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/nodatafound.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  List<PersonModel>? person;
  final DismissDirection _dismissDirection = DismissDirection.endToStart;

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
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定删除以下人员?\n\n${item.name}',
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

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    required this.item,
    required this.onDelete,
    required this.onTap,
    required this.dismissDirection,
  });

  final PersonModel item;
  final DismissDirection dismissDirection;
  final void Function(PersonModel) onDelete;
  final void Function(PersonModel) onTap;

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
          // const CustomSemanticsAction(label: '完成'): _handleDelete,
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
                  trailing:
                      Icon(Icons.delete, color: Colors.white, size: 36.0))),
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                  color: theme.canvasColor,
                  border:
                      Border(bottom: BorderSide(color: theme.dividerColor))),
              child: ListTile(
                onTap: _handleTap,
                title: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(item.updatedAt),
              ),
            ),
          ),
        ));
  }
}
