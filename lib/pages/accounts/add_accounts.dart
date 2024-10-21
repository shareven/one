import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one/model/cost_type_model.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/loading.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/widgets/date_time_picker.dart';
import 'package:intl/intl.dart';

class AddAccounts extends StatefulWidget {
  const AddAccounts({super.key});

  @override
  State<AddAccounts> createState() => _AddAccountsState();
}

class _AddAccountsState extends State<AddAccounts> {
  final _formKey = GlobalKey<FormState>();
  var _isIncome = false;
  int? _money;
  CostTypeModel? _costType;
  // Date time;
  DateTime _time = DateTime.now();
  String? _remark;
  List<CostTypeModel> _typeList = [];
  List<CostTypeModel> _typeListIsIncome = []; //收入的类型
  List<CostTypeModel> _typeListNotIncome = []; //支出的类型
  bool _enableBtn = false;

  void _getCostType() async {
    //loading

    var res = await DataService.getCostType();
    if (res.code != 111 && mounted) {
      List resList = res.data;
      List<CostTypeModel> typeList = resList.map((v) {
        return CostTypeModel.fromJson(v);
      }).toList();

      setState(() {
        _typeListIsIncome = typeList.where((v) => v.isIncome).toList();
        _typeListNotIncome = typeList.where((v) => !v.isIncome).toList();
        _typeList = _typeListNotIncome;
        _costType = _typeListNotIncome.first;
      });
    }
  }

  void _saveData() async {
    var form = _formKey.currentState;
    if (_costType != null && form!.validate()) {
      form.save();

      Map<String, dynamic> data = {
        "isIncome": _isIncome,
        "costType": _costType!.name,
        "money": _money,
        "time": DateFormat("yyyy-MM-dd").format(_time),
        "remark": _remark
      };
      Loading.showLoading(context);
      ResultData res = await DataService.addAccounts(data);

      if (res.code != 111 && mounted) {
        Loading.hideLoading(context);
        Navigator.pop(context, res.data);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCostType();
  }

  Widget buildTypeList(BuildContext context) {
    if (_typeList.isNotEmpty) {
      return DropdownButton<CostTypeModel>(
        value: _costType,
        onChanged: (CostTypeModel? value) {
          setState(() {
            _costType = value;
          });
        },
        items: _typeList.map<DropdownMenuItem<CostTypeModel>>((value) {
          return DropdownMenuItem<CostTypeModel>(
            value: value,
            child: Text(value.name, textAlign: TextAlign.center),
          );
        }).toList(),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget buildType(BuildContext context) {
    return InputDecorator(
        decoration: const InputDecoration(
          labelText: "分类",
          hintText: "选择一个分类",
          contentPadding: EdgeInsets.zero,
        ),
        isEmpty: _costType == null,
        textAlign: TextAlign.right,
        child: buildTypeList(context));
  }

  void updateType(value) {
    setState(() {
      _isIncome = value;
      _typeList = value ? _typeListIsIncome : _typeListNotIncome;
      _costType = _typeList.first;
    });
  }

  Widget buildIsIcome(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          title: const Text("支出"),
          value: false,
          onChanged: (value) {
            updateType(value);
          },
          groupValue: _isIncome,
        ),
        RadioListTile(
          title: const Text("收入"),
          value: true,
          onChanged: (value) {
            updateType(value);
          },
          groupValue: _isIncome,
        ),
      ],
    );
  }

  Widget buildTime(BuildContext context) {
    return DateTimePicker(
      labelText: '日期',
      selectedDate: _time,
      selectDate: (DateTime date) {
        setState(() {
          _time = date;
        });
      },
    );
  }

  Widget buildMoney(BuildContext context) {
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      onSaved: (value) {
        setState(() {
          _money = value!.trim() == "" ? null : int.parse(value.trim());
        });
      },
      validator: (val) {
        return val == null || val == "" ? "不能为空" : null;
      },
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          labelText: "金额", prefixText: "￥", border: OutlineInputBorder()),
    );
  }

  Widget buildRemark(BuildContext context) {
    return TextFormField(
      onSaved: (value) {
        setState(() {
          _remark = value ?? '';
        });
      },
      maxLength: 15,
      decoration:
          const InputDecoration(labelText: "备注", border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var formKey = _formKey;
    return Scaffold(
        appBar: AppBar(
          title: const Text('添加账单'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.done),
                onPressed: _enableBtn ? _saveData : null)
          ],
        ),
        body: DropdownButtonHideUnderline(
          child: Form(
            key: formKey,
            onChanged: () =>
                setState(() => _enableBtn = _formKey.currentState!.validate()),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                const SizedBox(height: 4),
                buildIsIcome(context),
                const SizedBox(height: 20),
                buildType(context),
                const SizedBox(height: 20),
                buildTime(context),
                const SizedBox(height: 20),
                buildMoney(context),
                const SizedBox(height: 20),
                buildRemark(context)
              ],
            ),
          ),
        ));
  }
}
