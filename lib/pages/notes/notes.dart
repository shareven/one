import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:one/model/note_model.dart';
import 'package:one/pages/notes/add_notes.dart';
import 'package:one/pages/notes/edit_notes.dart';
import 'package:one/utils/data_service.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/nodatafound.dart';
import 'package:one/widgets/main_drawer.dart';

class Notes extends StatefulWidget {
  static const String sName = "/notes";

  const Notes({super.key});
  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final DismissDirection _dismissDirection = DismissDirection.endToStart;
  List<NoteModel>? _notesList;
  RefreshController? _refreshController;
  String _searchWord = "";
  final TextEditingController _searchController =
      TextEditingController(text: "");

  final FocusNode _focusNodeSearch = FocusNode();

  @override
  void initState() {
    //
    _getNotesData();
    _refreshController = RefreshController();
    super.initState();
  }

  Future<void> _getNotesData() async {
    String searchData = _searchWord.isEmpty ? "" : '"content":"$_searchWord"';
    String whereData = searchData.isNotEmpty ? '{$searchData}' : '{}';
    ResultData res = await DataService.getNoteFilter(whereData);
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<NoteModel> notesData = resList.map((v) {
        return NoteModel.fromJson(v);
      }).toList();

      setState(() {
        _notesList = notesData;
      });
    }
  }

  void _handleRefresh() async {
    _refreshController?.requestRefresh();
    await _getNotesData();
    _refreshController?.refreshCompleted();
    // _refreshController.sendBack(true, RefreshStatus.completed);
  }

  void handleUndo(NoteModel item, int insertionIndex) {
    setState(() {
      _notesList?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(NoteModel item) {
    final int insertionIndex = _notesList!.indexOf(item);
    setState(() {
      _notesList!.remove(item);
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          '确定删除以下便签?\n\n${item.updatedAt}\n${item.content}',
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
              _deleteNotes(item, insertionIndex);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteNotes(NoteModel item, int insertionIndex) async {
    var res = await DataService.deleteNote(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据

      showErrorMsg(res.data.toString());
    }
  }

  void _goToEditPage(item) async {
    var res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => EditNotes(notes: item)));
    if (res != null && mounted) {
      _getNotesData();
    }
  }

  void _goToAddPage() async {
    var res = await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => const AddNotes()));

    if (res != null && mounted) {
      //处理页面返回的回调
      setState(() {
        _notesList?.insert(0, NoteModel.fromJson(res));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_notesList == null || _refreshController == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_notesList!.isEmpty) {
      body = const Nodatafound();
    } else {
      body = SmartRefresher(
        header: const WaterDropHeader(),
        footer: null,
        enablePullUp: false,
        enablePullDown: true,
        controller: _refreshController!,
        onRefresh: _handleRefresh,
        child: ListView(
          children: _notesList!.map<Widget>((NoteModel item) {
            return _LeaveBehindListItem(
                dismissDirection: _dismissDirection,
                item: item,
                onTap: (val) {
                  _goToEditPage(val);
                },
                onDelete: _handleDelete);
          }).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Theme(
                data: ThemeData.dark(),
                child: TextField(
                  onChanged: (e) {
                    setState(() {
                      _searchWord = e.trim();
                    });
                  },
                  focusNode: _focusNodeSearch,
                  controller: _searchController,
                  onSubmitted: (e) => _handleRefresh(),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.all(1),
                    hintText: "搜索便签",
                  ),
                ),
              ),
            ),
            IconButton(
              iconSize: 20,
              onPressed: () {
                _focusNodeSearch.unfocus();
                _handleRefresh();
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
      drawer: const MainDrawer(),
      body: body,
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

  final NoteModel item;
  final DismissDirection dismissDirection;
  final void Function(NoteModel) onDelete;
  final void Function(NoteModel) onTap;

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
          child: Container(
            decoration: BoxDecoration(
                color: theme.canvasColor,
                border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: ListTile(
              onTap: _handleTap,
              title: Text(
                item.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(item.updatedAt),
            ),
          ),
        ));
  }
}
