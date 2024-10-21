import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:one/provide/audio_provide.dart';
import 'package:one/utils/local_storage.dart';

class SettingBook extends StatefulWidget {
  const SettingBook({super.key});
  @override
  State<SettingBook> createState() => _SettingBookState();
}

class _SettingBookState extends State<SettingBook> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDirectory = "";
  final TextEditingController _skipSecondsStartController =
      TextEditingController(text: "0");

  final FocusNode _focusNodeSkipSecondsStart = FocusNode();
  final TextEditingController _skipSecondsEndController =
      TextEditingController(text: "0");

  final FocusNode _focusNodeSkipSecondsEnd = FocusNode();
  bool _enableBtn = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
    _skipSecondsStartController.dispose();
    _focusNodeSkipSecondsStart.dispose();
    _skipSecondsEndController.dispose();
    _focusNodeSkipSecondsEnd.dispose();
  }

  void _getData() async {
    List<Duration> list = await LocalStorage.getPlaySkipSeconds();
    String localBookDirectory = await LocalStorage.getLocalBookDirectory();
    _skipSecondsStartController.text = list[0].inSeconds.toString();
    _skipSecondsEndController.text = list[1].inSeconds.toString();
    setState(() {
      _selectedDirectory = localBookDirectory;
    });
  }

  void _post() async {
    var isSuccess = await LocalStorage.setPlaySkipSeconds([
      _skipSecondsStartController.text.trim(),
      _skipSecondsEndController.text.trim()
    ]);

    await LocalStorage.setLocalBookDirectory(_selectedDirectory);

    if (isSuccess && mounted) {
      context.read<AudioProvide>().setPlayBookItems();

      Navigator.pop(context);
    }
  }

  selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
    }
    setState(() {
      _selectedDirectory = selectedDirectory ?? "";
    });
  }

  Widget buildLocalBook(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: FilledButton(
            onPressed: selectDirectory,
            child: const Text("选择音频目录 | Select audio directory"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(_selectedDirectory),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("设置 | Setting"),
          actions: [
            IconButton(
                onPressed: _enableBtn ? _post : null,
                icon: const Icon(Icons.check))
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () =>
              setState(() => _enableBtn = _formKey.currentState!.validate()),
          child: ListView(
            children: [
              buildLocalBook(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Text("跳过片头秒数 | Skip opening"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是数字 | Must number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeSkipSecondsStart,
                  controller: _skipSecondsStartController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片头秒数 | Skip opening",
                    suffixText: "s",
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Text("跳过片尾秒数 | Skip the end"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是数字 | Must number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeSkipSecondsEnd,
                  controller: _skipSecondsEndController,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "跳过片尾秒数 | Skip the end",
                    suffixText: "s",
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
