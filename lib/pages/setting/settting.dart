import 'package:flutter/material.dart';
import 'package:one/pages/setting/backup_restore.dart';
import 'package:one/pages/setting/setting_default_page.dart';
import 'package:one/pages/setting/setting_theme.dart';
import 'package:one/widgets/main_drawer.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});
  static const String sName = "/setting";
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      drawer: const MainDrawer(),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.app_settings_alt_rounded,
            ),
            title: const Text("设置默认启动页面"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const SettingDefaultPage())),
          ),
          ListTile(
            leading: const Icon(
              Icons.color_lens_outlined,
            ),
            title: const Text("设置主题色"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const SettingTheme())),
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_backup_restore_rounded,
            ),
            title: const Text("备份与还原数据库"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const BackupRestore())),
          )
        ],
      ),
    );
  }
}
