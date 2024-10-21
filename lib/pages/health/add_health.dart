import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:one/model/person_model.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/widgets/date_time_picker.dart';

class AddHealth extends StatefulWidget {
  const AddHealth({super.key});

  @override
  State<AddHealth> createState() => _AddHealthState();
}

class _AddHealthState extends State<AddHealth> {
  final _formKey = GlobalKey<FormState>();

  double? _height;
  double? _weight;
  double? _bmi;
  String? _bmiTip;
  PersonModel? _person;
  // Date time;
  DateTime _time = DateTime.now();

  List<PersonModel> _persionList = [];
  bool _enableBtn = false;
  final TextEditingController _heightTextEditingController =
      TextEditingController();
  final TextEditingController _weightTextEditingController =
      TextEditingController();

  void _getPersons() async {
    //loading

    var res = await DataService.getPerson();
    if (res.code != 111) {
      List resList = res.data;
      List<PersonModel> persionList = resList.map((v) {
        return PersonModel.fromJson(v);
      }).toList();
      if (mounted) {
        setState(() {
          _persionList = persionList;
          _person = persionList.first;
        });
      }
    }
  }

  void _saveData() async {
    var form = _formKey.currentState;
    if (form!.validate() && _person != null) {
      form.save();

      Map<String, dynamic> data = {
        "person": _person!.name,
        "height": _height,
        "weight": _weight,
        "bmi": _bmi,
        "time": DateFormat("yyyy-MM-dd").format(_time),
      };

      ///保存身高到本地缓存
      LocalStorage.setHeightVal(_height);
      Loading.showLoading(context);
      ResultData res = await DataService.addHealth(data);

      if (res.code != 111 && mounted) {
        Loading.hideLoading(context);
        Navigator.pop(context, res.data);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPersons();
    _getHeight();
  }

  ///获取本地保存的身高值
  Future<void> _getHeight() async {
    String? val = await LocalStorage.getHeightVal();
    if (val != null && val.isNotEmpty && mounted) {
      setState(() {
        _heightTextEditingController.text = val;
        _height = double.parse(val);
      });
    }
  }

  Widget buildPersonList(BuildContext context) {
    if (_person != null && _persionList.isNotEmpty) {
      return DropdownButton<PersonModel>(
        value: _person,
        onChanged: (PersonModel? value) {
          setState(() {
            _person = value;
          });
        },
        items: _persionList.map<DropdownMenuItem<PersonModel>>((value) {
          return DropdownMenuItem<PersonModel>(
            value: value,
            child: Text(value.name, textAlign: TextAlign.center),
          );
        }).toList(),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget buildPerson(BuildContext context) {
    return InputDecorator(
        decoration: const InputDecoration(
          labelText: "名字",
          hintText: "选择一个名字",
          contentPadding: EdgeInsets.zero,
        ),
        isEmpty: _person == null,
        textAlign: TextAlign.right,
        child: buildPersonList(context));
  }

  Widget buildTime(BuildContext context) {
    return DateTimePicker(
      labelText: '日期',
      selectedDate: _time,
      selectDate: (DateTime date) {
        if (mounted) {
          setState(() {
            _time = date;
          });
        }
      },
    );
  }

  Widget buildheight(BuildContext context) {
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))
      ],
      onChanged: (value) {
        setState(() {
          _height = value == "" ? null : double.parse(value);
        });
        _computeBMI();
      },
      // focusNode: _heightFocusNode,
      validator: (val) {
        return val == null || val.trim() == ""
            ? "不能为空"
            : val.trim() == "0"
                ? "不能为0"
                : null;
      },
      onFieldSubmitted: (v) {
        if (_enableBtn) {
          _saveData();
        }
      },
      textInputAction: TextInputAction.done,
      controller: _heightTextEditingController,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          labelText: "身高（m）", prefixText: "￥", border: OutlineInputBorder()),
    );
  }

  Widget buildWeight(BuildContext context) {
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))
      ],
      onChanged: (value) {
        setState(() {
          _weight = value == "" ? null : double.parse(value);
        });
        _computeBMI();
      },
      onFieldSubmitted: (v) {
        if (_enableBtn) {
          _saveData();
        }
      },
      textInputAction: TextInputAction.done,
      controller: _weightTextEditingController,
      validator: (val) {
        return val == null || val.trim() == ""
            ? "不能为空"
            : val.trim() == "0"
                ? "不能为0"
                : null;
      },
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
          labelText: "体重（kg）", prefixText: "￥", border: OutlineInputBorder()),
    );
  }

  /// 计算bmi 成人
  _computeBMI() {
    if (mounted &&
        _weight != null &&
        _height != null &&
        _height != null &&
        _formKey.currentState!.validate()) {
      double bmi =
          double.parse((_weight! / (_height! * _height!)).toStringAsFixed(2));
      String tip;
      if (bmi < 18.5) {
        tip = "体重过低";
      } else if (bmi < 18.5) {
        tip = "体重过低";
      } else if (bmi >= 40.0) {
        tip = "Ⅲ度肥胖";
      } else if (bmi >= 35.0) {
        tip = "II度肥胖";
      } else if (bmi >= 30.0) {
        tip = "I度肥胖";
      } else if (bmi >= 25.0) {
        tip = "肥胖前期";
      } else {
        tip = "正常范围";
      }

      setState(() {
        _bmi = bmi;
        _bmiTip = tip;
      });
    }
  }

  @override
  void dispose() {
    _heightTextEditingController.dispose();
    _weightTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formKey = _formKey;
    return Scaffold(
        appBar: AppBar(
          title: const Text('添加健康信息'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.done),
                onPressed: _enableBtn ? _saveData : null),
          ],
        ),
        body: DropdownButtonHideUnderline(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () =>
                setState(() => _enableBtn = _formKey.currentState!.validate()),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                const SizedBox(height: 4),
                buildPerson(context),
                const SizedBox(height: 20),
                buildTime(context),
                const SizedBox(height: 20),
                buildWeight(context),
                const SizedBox(height: 20),
                buildheight(context),
                const SizedBox(height: 20),
                Text("成人BMI: ${_bmi ?? ''}"),
                Text(
                  _bmiTip != null ? "提示：$_bmiTip" : "",
                  style: TextStyle(
                      color: _bmiTip == "正常范围" ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
        ));
  }
}
