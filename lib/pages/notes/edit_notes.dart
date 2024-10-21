import 'package:flutter/material.dart';
import 'package:one/model/note_model.dart';
import 'package:one/utils/data_service.dart';
import 'package:one/utils/Loading.dart';
import 'package:one/utils/result_data.dart';

class EditNotes extends StatefulWidget {
  final NoteModel notes;
  const EditNotes({super.key, required this.notes});
  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  String? _content;

  TextEditingController? _textController;

  @override
  void initState() {
    super.initState();
    _content = widget.notes.content;
    _textController = TextEditingController(text: widget.notes.content);
  }

  _saveData() async {
    setState(() {
      _content = _textController!.text;
    });
    if (_content != null) {
      Map<String, dynamic> data = {"content": _content};
      Loading.showLoading(context);
      ResultData res = await DataService.putNote(widget.notes.id, data);

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
        title: const Text("编辑便签"),
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
            controller: _textController,
            autofocus: true,
            maxLines: 50,
            // onChanged: (value) {
            //   setState(() {
            //     _content = value;
            //   });
            // },
            decoration: const InputDecoration(
              hintText: "便签,开始记录",
            ),
          ),
        ),
      ),
    );
  }
}
