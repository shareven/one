import 'package:flutter/material.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';

class AddPerson extends StatefulWidget {
  const AddPerson({super.key});

  @override
  State<AddPerson> createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  String? _name;

  void _saveData() async {
    if (_name != null) {
      Map<String, dynamic> data = {
        "name": _name,
      };
      Loading.showLoading(context);
      ResultData res = await DataService.addPerson(data);
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
        title: const Text("添加人员"),
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
            decoration: const InputDecoration(hintText: "人员名称"),
          ),
        ),
      ),
    );
  }
}
