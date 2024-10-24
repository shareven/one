
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LeaveBehindListItem extends StatelessWidget {
  const LeaveBehindListItem({
    super.key,
    required this.dismissibleKey,
    required this.titleText,
    required this.subtitle,
    required this.onDelete, 
    this.onTap, 
    this.trailing, 
    this.isThreeLine= false, 
  });

  final Key dismissibleKey;
  final String titleText;
  final Widget subtitle;
  final Widget? trailing;
  final Function onDelete;
  final GestureTapCallback? onTap;
  final bool isThreeLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
        customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
          const CustomSemanticsAction(label: '删除'): () => onDelete,
        },
        child: Dismissible(
          key: dismissibleKey,
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection direction) {
            onDelete();
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
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                  color: theme.canvasColor,
                  border:
                      Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.2)))),
              child: ListTile(
                title: Text(
                  titleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: onTap,
                subtitle: subtitle,
                trailing:trailing,
                isThreeLine:isThreeLine,
              ),
            ),
          ),
        ));
  }
}
