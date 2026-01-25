import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one/provider/audio_provider.dart';
import 'package:one/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:one/model/book_model.dart';
import 'package:one/pages/audio/add_book.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/json_storage.dart';

class Books extends StatefulWidget {
  const Books({super.key});
  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final DismissDirection _dismissDirection = DismissDirection.endToStart;
  List<BookModel>? _books;
  BookModel? _currentBook;

  @override
  void initState() {
    super.initState();
    _getBookData();
  }

  Future _getBookData() async {
    List<BookModel> books = await JsonStorage.getBooks();
    BookModel? book = await LocalStorage.getCurrentBookVal();
    setState(() {
      _books = books;
      _currentBook = book;
    });
  }

  _setCurrentBook(BookModel book) async {
    setState(() {
      _currentBook = book;
    });
    await LocalStorage.setCurrentBookVal(book);
  }

  void handleUndo(BookModel item, int insertionIndex) {
    setState(() {
      _books?.insert(insertionIndex, item);
    });
  }

  void _handleDelete(BookModel item) {
    final int insertionIndex = _books!.indexOf(item);
    setState(() {
      _books!.remove(item);
    });
    showDeleteDialog(
      context,
      '确定删除以下书?\n\n${item.name}',
      cancelFn: () => handleUndo(item, insertionIndex),
      deleteFn: () => _deleteBook(item),
    );
  }

  Future _deleteBook(BookModel book) async {
    if (_currentBook != null && _currentBook!.name == book.name) {
      await LocalStorage.setCurrentBookVal(null);
      if (mounted) context.read<AudioProvider>().setPlayBookItems();
      setState(() {
        _currentBook = null;
      });
    }
    await JsonStorage.deleteBook(book.name);
    List<BookModel> books = await JsonStorage.getBooks();

    setState(() {
      _books = books;
    });
  }

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

  Widget _buildBookCover(String artUrl) {
    final colorScheme = Theme.of(context).colorScheme;

    if (artUrl.startsWith('color:')) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _parseColor(artUrl),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.book, color: Colors.white, size: 24),
      );
    }
    final file = File(artUrl);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.book, color: colorScheme.onSurfaceVariant, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("书架"),
        actions: [
          IconButton.filled(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBook()),
              );
              _getBookData();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _books == null
          ? const Center(child: CircularProgressIndicator())
          : _books!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "还没有书籍",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBook(),
                        ),
                      );
                      _getBookData();
                    },
                    child: const Text("添加书籍"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _books!.length,
              itemBuilder: (context, index) {
                final book = _books![index];
                final isCurrent = book.name == _currentBook?.name;
                return Dismissible(
                  key: Key(book.name),
                  direction: _dismissDirection,
                  background: Container(
                    color: colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(Icons.play_arrow, color: colorScheme.onPrimary),
                  ),
                  secondaryBackground: Container(
                    color: colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: colorScheme.onError),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _handleDelete(book);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await _setCurrentBook(book);
                        if (mounted) {
                          context.read<AudioProvider>().setPlayBookItems();
                        }
                      },
                      child: ListTile(
                        leading: _buildBookCover(book.artUrl),
                        title: Text(
                          book.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          book.isMetadataMode
                              ? "${book.totalTracks}集"
                              : "${book.start}-${book.end}集",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: isCurrent
                            ? Icon(
                                Icons.play_circle_filled,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
