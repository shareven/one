import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/audio_scanner.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';
import 'package:one/utils/json_storage.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final TextEditingController _bookDirectoryController = TextEditingController(
    text: "",
  );

  String _bookDirectory = "";
  List<BookModel> _scannedBooks = [];
  Set<String> _selectedBooks = {};
  bool _isScanning = false;

  static Color _parseColor(String colorStr) {
    if (colorStr.startsWith('color:')) {
      List<String> parts = colorStr.substring(6).split(',');
      if (parts.length == 3) {
        return Color.fromRGBO(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          1.0,
        );
      }
    }
    return Colors.grey;
  }

  Widget _buildBookCover(String artUrl, double size) {
    if (artUrl.startsWith('color:')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _parseColor(artUrl),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.book, color: Colors.white),
      );
    } else {
      bool exists = File(artUrl).existsSync();
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: exists ? null : Colors.grey[300],
          image: exists
              ? DecorationImage(
                  image: FileImage(File(artUrl)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !exists
            ? const Icon(Icons.broken_image, color: Colors.grey)
            : null,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initBookDirectory();
  }

  Future _initBookDirectory() async {
    String path = await LocalStorage.getLocalBookDirectory();
    setState(() {
      _bookDirectory = path;
      _bookDirectoryController.text = path;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bookDirectoryController.dispose();
  }

  Future _selectBookDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await LocalStorage.setLocalBookDirectory(selectedDirectory);
      setState(() {
        _bookDirectory = selectedDirectory;
        _bookDirectoryController.text = selectedDirectory;
      });
      showSuccessMsg("听书目录已设置: $selectedDirectory");
    }
  }

  Future _scanBooksDirectory() async {
    if (_bookDirectory.isEmpty) {
      showErrorMsg("请先设置听书目录");
      return;
    }

    setState(() {
      _isScanning = true;
      _scannedBooks = [];
      _selectedBooks = {};
    });

    try {
      List<BookModel> books = await AudioScanner.scanBooksDirectory(
        _bookDirectory,
      );
      setState(() {
        _scannedBooks = books;
        _selectedBooks = Set.from(books.map((e) => e.name));
      });

      if (books.isEmpty) {
        showErrorMsg("未找到任何听书书籍");
      } else {
        showSuccessMsg("扫描完成，找到 ${books.length} 本书");
      }
    } catch (e) {
      showErrorMsg("扫描失败: $e");
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _toggleBookSelection(String bookName) {
    setState(() {
      if (_selectedBooks.contains(bookName)) {
        _selectedBooks.remove(bookName);
      } else {
        _selectedBooks.add(bookName);
      }
    });
  }

  void _selectAllBooks() {
    setState(() {
      if (_selectedBooks.length == _scannedBooks.length) {
        _selectedBooks.clear();
      } else {
        _selectedBooks = Set.from(_scannedBooks.map((e) => e.name));
      }
    });
  }

  Future _importSelectedBooks() async {
    if (_selectedBooks.isEmpty) {
      showErrorMsg("请先选择要导入的书籍");
      return;
    }

    int importCount = 0;

    for (var book in _scannedBooks) {
      if (_selectedBooks.contains(book.name)) {
        await JsonStorage.saveBook(book);
        importCount++;
      }
    }

    if (mounted) {
      showSuccessMsg("成功导入 $importCount 本书");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("添加书")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bookDirectoryController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(1),
                      hintText: "听书目录路径",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: FilledButton(
                    onPressed: _selectBookDirectory,
                    child: const Text("设置"),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isScanning ? null : _scanBooksDirectory,
                child: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("扫描听书目录"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "目录规范:\n"
                "1. 在听书目录下创建文件夹作为书名\n"
                "2. 将音频文件放入书名文件夹中\n"
                "3. 支持格式: mp3, m4a, mp4, aac, flac, ogg, wav, wma\n"
                "4. 可在书名文件夹中放置任意jpg/png图片作为封面\n\n"
                "示例:\n"
                "book/\n"
                "├── 从箭术开始修行/\n"
                "│   ├── 从箭术开始修行1.m4a\n"
                "│   ├── 从箭术开始修行2.m4a\n"
                "│   └── cover.jpg  (可选封面)\n"
                "├── 另一本书/\n"
                "│   ├── 01.mp3\n"
                "│   └── 02.mp3\n"
                "└── 第三本书/\n"
                "    └── audio.m4a",
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_scannedBooks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _selectAllBooks,
                    icon: Icon(
                      _selectedBooks.length == _scannedBooks.length
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    label: Text(
                      _selectedBooks.length == _scannedBooks.length
                          ? "取消全选"
                          : "全选",
                    ),
                  ),
                  Text("${_selectedBooks.length}/${_scannedBooks.length} 本"),
                ],
              ),
            ),
            Column(
              children: _scannedBooks.map((book) {
                final isSelected = _selectedBooks.contains(book.name);
                return ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleBookSelection(book.name),
                  ),
                  title: Text(book.name),
                  subtitle: Text("${book.totalTracks} 集"),
                  trailing: _buildBookCover(book.artUrl, 40),
                  selected: isSelected,
                  onTap: () => _toggleBookSelection(book.name),
                );
              }).toList(),
            ),
            if (_selectedBooks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _importSelectedBooks,
                    child: Text("导入选中书籍 (${_selectedBooks.length})"),
                  ),
                ),
              ),
          ],
          if (_scannedBooks.isEmpty && !_isScanning)
            const Expanded(
              child: Center(
                child: Text(
                  "点击上方按钮扫描听书目录\n将自动导入所有子文件夹中的书籍",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
