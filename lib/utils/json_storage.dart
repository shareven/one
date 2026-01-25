import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/utils.dart';

class JsonStorage {
  static const String fileName = "books.json";

  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  static Future<void> saveBooks(List<BookModel> books) async {
    try {
      final file = File(await _getFilePath());
      String json = jsonEncode(books.map((e) => e.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      showErrorMsg("保存书籍失败: $e");
    }
  }

  static Future<List<BookModel>> getBooks() async {
    try {
      final file = File(await _getFilePath());
      if (!await file.exists()) return [];
      
      String content = await file.readAsString();
      if (content.isEmpty) return [];

      List<dynamic> list = jsonDecode(content);
      return list.map((e) => BookModel.fromJson(e)).toList();
    } catch (e) {
      print("获取书籍失败: $e");
      return [];
    }
  }

  static Future<void> saveBook(BookModel book) async {
    List<BookModel> books = await getBooks();
    // Remove existing if any
    books.removeWhere((e) => e.name == book.name);
    // Insert at top
    books.insert(0, book);
    await saveBooks(books);
  }

  static Future<void> deleteBook(String bookName) async {
    List<BookModel> books = await getBooks();
    books.removeWhere((e) => e.name == bookName);
    await saveBooks(books);
  }
}
