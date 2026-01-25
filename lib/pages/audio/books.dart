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
import 'package:one/utils/json_storage.dart';

class Books extends StatefulWidget {
  const Books({super.key});
  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> with TickerProviderStateMixin {
  final DismissDirection _dismissDirection = DismissDirection.endToStart;
  List<BookModel>? _books;
  BookModel? _currentBook;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _getBookData();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "我的书架",
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: IconButton.filled(
              onPressed: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AddBook(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ),
                            ),
                            child: child,
                          );
                        },
                  ),
                );
                _getBookData();
              },
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _books == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "加载中...",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _books!.isEmpty
          ? _buildEmptyState()
          : _buildBooksList(),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 60,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "还没有添加书籍",
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "点击右上角的 + 按钮添加您的第一本书",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddBook(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ),
                          ),
                          child: child,
                        );
                      },
                ),
              );
              _getBookData();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text("添加书籍"),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _books!.length,
              itemBuilder: (context, index) {
                final book = _books![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LeaveBehindListItem(
                    item: book,
                    currentBook: _currentBook,
                    dismissDirection: _dismissDirection,
                    onTap: (val) async {
                      await _setCurrentBook(book);
                      if (mounted) {
                        context.read<AudioProvider>().setPlayBookItems();
                      }
                    },
                    onDelete: _handleDelete,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LeaveBehindListItem extends StatelessWidget {
  const _LeaveBehindListItem({
    required this.item,
    required this.currentBook,
    required this.dismissDirection,
    required this.onDelete,
    required this.onTap,
  });

  final BookModel item;
  final BookModel? currentBook;
  final DismissDirection dismissDirection;
  final void Function(BookModel) onDelete;
  final void Function(BookModel) onTap;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCurrent = item.name == currentBook?.name;

    return Card(
      elevation: 0,
      color: isCurrent ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Dismissible(
        key: ObjectKey(item),
        direction: dismissDirection,
        onDismissed: (DismissDirection direction) {
          onDelete(item);
        },
        background: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Icon(
            Icons.play_arrow_rounded,
            color: colorScheme.onPrimary,
            size: 32,
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_rounded,
            color: colorScheme.onError,
            size: 32,
          ),
        ),
        child: InkWell(
          onTap: () => onTap(item),
          borderRadius: BorderRadius.circular(16),
          onLongPress: () async {
            await Clipboard.setData(
              ClipboardData(text: item.artUrl + item.name),
            );
            showSuccessMsg("已复制图片链接和书名");
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildBookCover(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isMetadataMode
                            ? "${item.totalTracks}集 (元数据模式)"
                            : "${item.start}-${item.end}集",
                        style: textTheme.bodyMedium?.copyWith(
                          color: isCurrent
                              ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent) ...[
                  Icon(
                    Icons.play_circle_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'book-cover-${item.name}',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildCoverContent(context),
        ),
      ),
    );
  }

  Widget _buildCoverContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.artUrl.startsWith('color:')) {
      return Container(
        color: _parseColor(item.artUrl),
        child: Icon(
          Icons.book_rounded,
          color: Colors.white.withOpacity(0.9),
          size: 28,
        ),
      );
    }

    final file = File(item.artUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 28,
            ),
          );
        },
      );
    }

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.book_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 28,
      ),
    );
  }
}
