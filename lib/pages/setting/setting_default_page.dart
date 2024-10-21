import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/utils/local_storage.dart';

class SettingDefaultPage extends StatefulWidget {
  const SettingDefaultPage({super.key});

  @override
  State<SettingDefaultPage> createState() => _SettingDefaultPageState();
}

class _SettingDefaultPageState extends State<SettingDefaultPage> {
  String defaultPage = Global.pages[0].route;
  @override
  void initState() {
    super.initState();
    getDefaultPage();
  }

  void getDefaultPage() async {
    String page = await LocalStorage.getDefaultPage();
    setState(() {
      defaultPage = page;
    });
  }

  void setDefaultPage(String page) async {
    setState(() {
      defaultPage = page;
    });
    await LocalStorage.setDefaultPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置默认启动页面"),
      ),
      body: ListView(
        children: Global.pages
            .map((e) => ListTile(
                  title: Text(e.name),
                  selected: e.route == defaultPage,
                  onTap: () => setDefaultPage(e.route),
                  trailing: e.route == defaultPage
                      ? Icon(
                          size: 20,
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
