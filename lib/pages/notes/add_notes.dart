import 'package:flutter/material.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  String? _content;

  void _saveData() async {
    if (_content != null) {
      Map<String, dynamic> data = {
        "content": _content,
      };
      Loading.showLoading(context);
      ResultData res = await DataService.addNote(data);

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
        title: const Text("添加便签"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed:
                _content != null && _content!.isNotEmpty ? _saveData : null,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          child: TextField(
            autofocus: true,
            maxLines: 50,
            onChanged: (value) {
              setState(() {
                _content = value;
              });
            },
            decoration: const InputDecoration(hintText: "便签,开始记录"),
          ),
        ),
      ),
    );
  }
}
