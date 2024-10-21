import 'package:flutter/material.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';

class AddCostType extends StatefulWidget {
  const AddCostType({super.key});

  @override
  State<AddCostType> createState() => _AddCostTypeState();
}

class _AddCostTypeState extends State<AddCostType> {
  String? _name;
  bool? _isIncome = false;

  void _saveData() async {
    if (_name != null) {
      Map<String, dynamic> data = {
        "name": _name,
        "isIncome": _isIncome,
      };
      Loading.showLoading(context);
      ResultData res = await DataService.addCostType(data);
      if (res.code != 111 && mounted) {
        Loading.hideLoading(context);

        Navigator.pop(context, res.data);
      }
    }
  }

  Widget buildIsIcome(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          title: const Text("支出"),
          value: false,
          onChanged: (value) {
            setState(() {
              _isIncome = value;
            });
          },
          groupValue: _isIncome,
        ),
        RadioListTile(
          title: const Text("收入"),
          value: true,
          onChanged: (value) {
            setState(() {
              _isIncome = value;
            });
          },
          groupValue: _isIncome,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加分类"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.done),
              onPressed: _name != null && _name!.isNotEmpty ? _saveData : null)
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          child: Column(
            children: [
              buildIsIcome(context),
              TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                maxLength: 8,
                decoration: const InputDecoration(hintText: "分类名称"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
