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
  final TextEditingController _bookDirectoryController =
      TextEditingController();
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
        child: Icon(Icons.book, color: Colors.white, size: size * 0.5),
      );
    }
    final file = File(artUrl);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  void initState() {
    super.initState();
    _initBookDirectory();
  }

  @override
  void dispose() {
    _bookDirectoryController.dispose();
    super.dispose();
  }

  Future _initBookDirectory() async {
    String path = await LocalStorage.getLocalBookDirectory();
    setState(() {
      _bookDirectory = path;
      _bookDirectoryController.text = path;
    });
  }

  Future _selectBookDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await LocalStorage.setLocalBookDirectory(selectedDirectory);
      setState(() {
        _bookDirectory = selectedDirectory;
        _bookDirectoryController.text = selectedDirectory;
      });
      showSuccessMsg("目录已设置");
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

      if (mounted) {
        setState(() {
          _scannedBooks = books;
          _selectedBooks = Set.from(books.map((e) => e.name));
          _isScanning = false;
        });

        if (books.isEmpty) {
          showErrorMsg("未找到书籍");
        } else {
          showSuccessMsg("找到 ${books.length} 本书");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        showErrorMsg("扫描失败: $e");
      }
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
      showErrorMsg("请选择要导入的书籍");
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
      showSuccessMsg("导入 $importCount 本书");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加书籍"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bookDirectoryController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "听书目录",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _selectBookDirectory,
                  child: const Text("选择"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isScanning ? null : _scanBooksDirectory,
                child: _isScanning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text("正在扫描..."),
                        ],
                      )
                    : const Text("扫描听书目录"),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "目录规范:\n"
              "1. 在听书目录下创建文件夹作为书名\n"
              "2. 将音频文件放入书名文件夹中\n"
              "3. 支持格式: mp3, m4a, mp4, aac, flac, ogg, wav, wma\n"
              "4. 可在书名文件夹中放置任意jpg/png图片作为封面",
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          if (_scannedBooks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _selectAllBooks,
                    child: Text(
                      _selectedBooks.length == _scannedBooks.length
                          ? "取消全选"
                          : "全选",
                    ),
                  ),
                  const Spacer(),
                  Text("${_selectedBooks.length}/${_scannedBooks.length} 本"),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scannedBooks.length,
                itemBuilder: (context, index) {
                  final book = _scannedBooks[index];
                  final isSelected = _selectedBooks.contains(book.name);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggleBookSelection(book.name),
                    title: Text(book.name, maxLines: 2),
                    subtitle: Text("${book.totalTracks} 集"),
                    secondary: _buildBookCover(book.artUrl, 48),
                  );
                },
              ),
            ),
            if (_selectedBooks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _importSelectedBooks,
                    child: Text("导入 (${_selectedBooks.length})"),
                  ),
                ),
              ),
          ],
          if (_scannedBooks.isEmpty && !_isScanning)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "点击上方按钮扫描听书目录",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
