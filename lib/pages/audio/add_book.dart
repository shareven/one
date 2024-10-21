import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/local_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  bool _enableBtn = false;
  final TextEditingController _bookNameController =
      TextEditingController(text: "");
  final TextEditingController _startController =
      TextEditingController(text: "1");
  final TextEditingController _endController = TextEditingController(text: "");
  final FocusNode _focusNodeBookName = FocusNode();
  final FocusNode _focusNodeStart = FocusNode();
  final FocusNode _focusNodeEnd = FocusNode();
  String? _artUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeBookName.dispose();
    _focusNodeStart.dispose();
    _focusNodeEnd.dispose();
    _bookNameController.dispose();
    _startController.dispose();
    _endController.dispose();
  }

  Future _seletctImg() async {
    FilePickerResult? res =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.count != 0 && res.files[0].path != null) {
      String imgPath = res.files[0].path!;
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String fileName = DateFormat("yyyyMMddHHmmss").format(DateTime.now()) +
          res.files[0].name;
      String newPath = join(documentsDirectory.path, fileName);

      await File(imgPath).copy(newPath);
      setState(() {
        _artUrl = newPath;
      });
    }
  }

  Future _post(BuildContext context) async {
    int? start = int.tryParse(_startController.text);
    int? end = int.tryParse(_endController.text);
    BookModel book =
        BookModel(_bookNameController.text, _artUrl!, start!, end!);
    List<BookModel> books = await LocalStorage.getBooksVal();
    int index = books.indexWhere((e) => e.name == book.name);
    if (index != -1) {
      books.removeAt(index);
    }
    books.insert(0, book);
    List list = books.map((e) => e.toJson()).toList();
    LocalStorage.setBooksVal(list);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("添加书"),
          actions: [
            IconButton(
                onPressed:
                    _enableBtn && _artUrl != null ? () => _post(context) : null,
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
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    if (v != null && v.trim().isEmpty) {
                      return "不能为空 | Required";
                    }
                    return null;
                  },
                  focusNode: _focusNodeBookName,
                  controller: _bookNameController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (e) => _focusNodeEnd.requestFocus(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "书名 | Book name",
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FilledButton(
                      onPressed: _seletctImg,
                      child: const Text("选择封面图片"),
                    ),
                  ),
                  _artUrl != null
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.file(
                            File(
                              _artUrl!,
                            ),
                            height: 40,
                          ),
                        )
                      : Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是正整数 | Must positive integer";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeStart,
                  controller: _startController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (e) => _focusNodeEnd.requestFocus(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "开始集数 | Start Episode",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  validator: (v) {
                    String val = v!.trim();
                    if (val.isEmpty) return "不能为空 | Required";
                    if (int.tryParse(val) == null || int.parse(val) < 0) {
                      return "不是正整数 | Must positive integer";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodeEnd,
                  controller: _endController,
                  onFieldSubmitted: _enableBtn && _artUrl != null
                      ? (e) => _post(context)
                      : null,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(1),
                    hintText: "结束集数 | End Episode",
                  ),
                ),
              ),
              textWidget(context),
            ],
          ),
        ));
  }

  Widget textWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "命名规则 | Naming convention",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "`书名`（目录名）/`书名`+`集数`+.m4a(文件名)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "`Book name` (directory name) / `Book name` + `Episode number` + .m4a (file name)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "例如 | For example:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传1.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传2.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "- 凡人修仙传/凡人修仙传3.m4a",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
