import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/utils/local_storage.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({super.key});

  @override
  State<SettingTheme> createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  int themeColor = Global.themeColor.alpha;
  @override
  void initState() {
    super.initState();
    getthemeColor();
  }

  void getthemeColor() async {
    int color = await LocalStorage.getThemeColor();
    setState(() {
      themeColor = color;
    });
  }

  void setthemeColor(int color) async {
    setState(() {
      themeColor = color;
    });
    await LocalStorage.setThemeColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置主题色（需重启）"),
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
                  onTap: () => setthemeColor(e.value),
                  trailing: e.value == themeColor
                      ?  Icon(
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
