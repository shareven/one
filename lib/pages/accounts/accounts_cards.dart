import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:one/model/account_model.dart';
import 'package:one/model/cost_type_model.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/widgets/leave_behind_list_item.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/nodatafound.dart';

class AccountsCards extends StatefulWidget {
  static const String sName = "/accountsCards";

  const AccountsCards({super.key});
  @override
  State<AccountsCards> createState() => _AccountsCardsState();
}

class _AccountsCardsState extends State<AccountsCards> {
  List<AccountModel>? _accountsList;
  RefreshController? _refreshController;
  int? _countAccounts;
  int _skipNum = 0;
  final int _limitNum = 10; //每次获取数量
  CostTypeModel all = CostTypeModel(-1, "全部", false);
  CostTypeModel _selectType = CostTypeModel(-1, "全部", false);
  List<CostTypeModel> _typeList = [];
  String _searchWord = "";
  final TextEditingController _searchController =
      TextEditingController(text: "");

  final FocusNode _focusNodeSearch = FocusNode();

  @override
  void initState() {
    //
    _getAccountsData();
    _getAccountsCountData();
    _getCostType();
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    super.dispose();
  }

  // 获取总数量
  void _getAccountsCountData() async {
    String searchData = _searchWord.isEmpty ? "" : '"remark":"$_searchWord"';
    String whereData = _selectType.id != -1
        ? searchData.isNotEmpty
            ? '{"costType": "${_selectType.name}", $searchData}'
            : '{"costType": "${_selectType.name}"}'
        : '{$searchData}';
    ResultData res = await DataService.getAccountsCount(whereData);
    if (res.code != 111 && mounted) {
      setState(() {
        _countAccounts = res.data["count"];
      });
    }
  }

  void _getCostType() async {
    ResultData res = await DataService.getCostType();
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<CostTypeModel> typeList = resList.map((v) {
        return CostTypeModel.fromJson(v);
      }).toList();
      typeList.insert(0, all);
      setState(() {
        _typeList = typeList;
      });
    }
  }

  Future<void> _getAccountsData() async {
    String searchData = _searchWord.isEmpty ? "" : '"remark":"$_searchWord"';
    String whereData = _selectType.id != -1
        ? searchData.isNotEmpty
            ? '{"costType": "${_selectType.name}", $searchData}'
            : '{"costType": "${_selectType.name}"}'
        : '{$searchData}';
    ResultData res =
        await DataService.getAccountsFilter(whereData, _skipNum, _limitNum);
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<AccountModel> accountsData = resList.map((v) {
        return AccountModel.fromJson(v);
      }).toList();
      _accountsList = _accountsList ?? [];
      List<AccountModel> newList =
          _skipNum == 0 ? accountsData : _accountsList! + accountsData;
      setState(() {
        _accountsList = newList;
      });
    }
  }

  void _selectCostType() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: PopScope(
          child: CupertinoPicker(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            itemExtent: 58,
            scrollController: FixedExtentScrollController(initialItem: 0),
            children: _typeList.map((i) {
              return Padding(
                  padding: const EdgeInsets.all(16), child: Text(i.name));
            }).toList(),
            onSelectedItemChanged: (v) {
              setState(() {
                _selectType = _typeList[v];
              });
            },
          ),
          onPopInvokedWithResult: (b, obj) {
            _skipNum = 0;
            _refreshController?.resetNoData();
            _getAccountsCountData();
            _handleRefresh();
          },
        ),
      ),
    );
  }

  void _handleRefresh() async {
    if (_countAccounts == null) return;
    int newSkip = 0;
    _refreshController?.resetNoData();
    if (newSkip <= _countAccounts!) {
      setState(() {
        _skipNum = newSkip;
      });
      await _getAccountsData();
      _refreshController?.refreshCompleted();
    } else {
      _refreshController?.refreshCompleted();
    }
  }

  void _onLoading() async {
    if (_countAccounts == null) return;
    int newSkip = _skipNum + _limitNum;
    if (newSkip <= _countAccounts!) {
      setState(() {
        _skipNum = newSkip;
      });
      await _getAccountsData();
      _refreshController?.loadComplete();
    } else {
      _refreshController?.loadNoData();
    }
  }

  void handleUndo(AccountModel item, int insertionIndex) {
    if (!mounted) return;
    setState(() {
      _accountsList?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(AccountModel item) {
    final int insertionIndex = _accountsList!.indexOf(item);
    setState(() {
      _accountsList!.remove(item);
    });
    showDeleteDialog(
      context,
      "确定删除以下账单?\n\n\"${item.time} ${item.costType} ￥${item.money} \"",
      cancelFn: () => handleUndo(item, insertionIndex),
      deleteFn: () => _deleteAccount(item, insertionIndex),
    );
  }

  void _deleteAccount(AccountModel item, int insertionIndex) async {
    ResultData res = await DataService.deleteAccounts(item.id);
    if (res.code == 111) {
      handleUndo(item, insertionIndex); //删除失败，还原数据
      showErrorMsg(res.data.toString());
    }
  }

  void _search() {
    _getAccountsCountData();
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_accountsList == null || _refreshController == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_accountsList!.isEmpty) {
      body = const Nodatafound();
    } else {
      body = SmartRefresher(
        header: const WaterDropHeader(),
        enablePullUp: true,
        enablePullDown: true,
        controller: _refreshController!,
        onLoading: _onLoading,
        onRefresh: _handleRefresh,
        child: ListView(
          children: _accountsList!.map<Widget>((AccountModel item) {
            return LeaveBehindListItem(
              dismissibleKey: ObjectKey(item),
              titleText: "￥${item.money}",
              subtitle: Text("${item.time}\n${item.remark}"),
              onDelete: () => _handleDelete(item),
              trailing: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.costType,
                    style: TextStyle(
                      fontSize: 14,
                      color: item.isIncome
                          ? Colors.green
                          : Theme.of(context).hintColor,
                    ),
                  )),
              isThreeLine: true,
            );
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
                  onSubmitted: (e) => _search(),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.all(1),
                    hintText: "搜索备注",
                  ),
                ),
              ),
            ),
            IconButton(
              iconSize: 20,
              onPressed: () {
                _focusNodeSearch.unfocus();
                _search();
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: _selectCostType,
              child: Text(
                _selectType.name,
                style: const TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: body,
    );
  }
}
