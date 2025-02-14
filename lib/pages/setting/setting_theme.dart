import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:one/config/global.dart';
import 'package:one/provider/theme_color_provider.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({super.key});

  @override
  State<SettingTheme> createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = context.watch<ThemeColorProvider>().themeColor ??
        Global.themeColor.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置主题色"),
      ),
      body: ListView(
        children: Global.themeColors
            .map((e) => ListTile(
                  title: Center(
                    child: Container(
                      height: 60,
                      width: 150,
                      decoration: BoxDecoration(
                        color: e,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onTap: () =>
                      context.read<ThemeColorProvider>().setThemeColor(e.value),
                  trailing: e.value == themeColor
                      ? Icon(
                          size: 30,
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Text(""),
                ))
            .toList(),
      ),
    );
  }
}
