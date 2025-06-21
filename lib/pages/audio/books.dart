import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:one/provider/audio_provider.dart';
import 'package:one/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:one/config/global.dart';
import 'package:one/model/book_model.dart';
import 'package:one/pages/audio/add_book.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/widgets/nodatafound.dart';

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
    List<BookModel> books = await LocalStorage.getBooksVal();
    BookModel? book = await LocalStorage.getCurrentBookVal();
    List<BookModel> notInList = [];
    for (var i = 0; i < Global.books.length; i++) {
      var e = Global.books[i];
      int index = books.indexWhere((x) => x.name == e.name);
      if (index == -1) {
        notInList.add(e);
      }
    }
    books.insertAll(0, notInList);
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
    List<BookModel> books = await LocalStorage.getBooksVal();
    books.removeWhere((e) => e.name == book.name);
    List list = books.map((e) => e.toJson()).toList();
    LocalStorage.setBooksVal(list);

    List<BookModel> notInList = [];
    for (var i = 0; i < Global.books.length; i++) {
      var e = Global.books[i];
      int index = books.indexWhere((x) => x.name == e.name);
      if (index == -1) {
        notInList.add(e);
      }
    }
    books.insertAll(0, notInList);
    setState(() {
      _books = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("书"),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const AddBook()));
                _getBookData();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: _books == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _books!.isEmpty
              ? const Nodatafound()
              : ListView(
                  children: _books!
                      .map((e) => _LeaveBehindListItem(
                          dismissDirection: _dismissDirection,
                          item: e,
                          currentBook: _currentBook,
                          onTap: (val) async {
                            await _setCurrentBook(e);
                            if (mounted)
                              context.read<AudioProvider>().setPlayBookItems();
                          },
                          onDelete: _handleDelete))
                      .toList(),
                ),
    );
  }
}

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    required this.item,
    required this.currentBook,
    required this.onDelete,
    required this.onTap,
    required this.dismissDirection,
  });

  final BookModel item;
  final BookModel? currentBook;
  final DismissDirection dismissDirection;
  final void Function(BookModel) onDelete;
  final void Function(BookModel) onTap;

  void _handleDelete() {
    onDelete(item);
  }

  void _handleTap() {
    onTap(item);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
        customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
          const CustomSemanticsAction(label: '删除'): _handleDelete,
        },
        child: Dismissible(
          key: ObjectKey(item),
          direction: dismissDirection,
          onDismissed: (DismissDirection direction) {
            _handleDelete();
          },
          background: Container(
              color: theme.primaryColor,
              child: const ListTile(
                  trailing: Icon(Icons.add, color: Colors.white, size: 36.0))),
          secondaryBackground: Container(
              color: Colors.pink,
              child: const ListTile(
                  contentPadding: EdgeInsets.all(14.0),
                  trailing:
                      Icon(Icons.delete, color: Colors.white, size: 36.0))),
          child: Container(
            decoration: BoxDecoration(
                color: theme.canvasColor,
                border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: ListTile(
              onTap: _handleTap,
              title: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onLongPress: () async {
                await Clipboard.setData(
                    ClipboardData(text: item.artUrl + item.name));
                showSuccessMsg("已复制图片链接和书名");
              },
              subtitle: Text("${item.start}-${item.end}集"),
              selected: item.name == currentBook?.name,
              selectedColor: Theme.of(context).colorScheme.primary,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(item.artUrl)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              trailing: item.name == currentBook?.name
                  ? Icon(
                      size: 20,
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Text(""),
            ),
          ),
        ));
  }
}
