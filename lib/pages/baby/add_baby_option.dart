import 'package:flutter/material.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';

class AddBabyOption extends StatefulWidget {
  const AddBabyOption({super.key});

  @override
  State<AddBabyOption> createState() => _AddBabyOptionState();
}

class _AddBabyOptionState extends State<AddBabyOption> {
  String? _name;

  void _saveData() async {
    if (_name != null) {
      Map<String, dynamic> data = {
        "name": _name,
      };
      Loading.showLoading(context);
      ResultData res = await DataService.addBabyoption(data);
      if (res.code != 111 && mounted) {
        Loading.hideLoading(context);

        Navigator.pop(context, res.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加宝贝活动选项"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.done),
              onPressed: _name != null && _name!.isNotEmpty ? _saveData : null)
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          child: TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            maxLength: 6,
            decoration: const InputDecoration(hintText: "宝贝活动选项"),
          ),
        ),
      ),
    );
  }
}
