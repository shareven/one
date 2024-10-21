import 'package:flutter/material.dart';
import 'package:one/pages/accounts/accounts_chart.dart';

class IncomeDataByMonth extends StatelessWidget {
  final List<MonthMoney> list;
  const IncomeDataByMonth(this.list, {super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      children: list
          .map((e) => Container(
                decoration: BoxDecoration(
                    color: e.time == "近一年"
                        ? theme.dividerColor.withOpacity(0.2)
                        : null,
                    border: Border(
                        bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2)))),
                child: ListTile(
                  leading: Text(e.time),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      e.incomeMoney == 0
                          ? const Text("0")
                          : Text(
                              "+${e.incomeMoney}",
                              style: const TextStyle(color: Colors.green),
                            ),
                      e.notincomeMoney == 0
                          ? const Text("0")
                          : Text(
                              "-${e.notincomeMoney}",
                              style: const TextStyle(color: Colors.pink),
                            )
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
