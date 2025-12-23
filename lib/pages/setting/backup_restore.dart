import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one/provider/theme_color_provider.dart';
import 'package:one/utils/database_helper.dart';
import 'package:one/utils/loading.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';
import 'package:provider/provider.dart';

class BackupRestore extends StatefulWidget {
  const BackupRestore({super.key});

  @override
  State<BackupRestore> createState() => _BackupRestoreState();
}

class _BackupRestoreState extends State<BackupRestore> {
  backup() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        Loading.showLoading(context);

        String rdataMapes = await LocalStorage.getAllStorage();
        await File(
          "$selectedDirectory/one-backup-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}.json",
        ).writeAsString(rdataMapes);

        await databaseHelper.backupDatabase(selectedDirectory);
        Loading.hideLoading(context);
        showSuccessMsg("备份完成");
      }
    } catch (e) {
      print(e);
      if (mounted) Loading.hideLoading(context);
      showErrorMsg("备份失败,$e");
    }
  }

  restoreDb() async {
    try {
      FilePickerResult? filesResult = await FilePicker.platform.pickFiles();

      if (filesResult != null &&
          filesResult.count != 0 &&
          filesResult.files[0].path != null) {
        if (filesResult.files[0].extension != "db") {
          showErrorMsg("请选择备份的db文件");
          return;
        }
        Loading.showLoading(context);
        Uint8List? data = await File(filesResult.files[0].path!).readAsBytes();
        databaseHelper.restoreDatabase(data);
        Loading.hideLoading(context);
        showSuccessMsg("db文件还原完成");
      }
    } catch (e) {
      print(e);
      if (mounted) Loading.hideLoading(context);
      showErrorMsg("db文件还原失败,$e");
    }
  }

  restoreJson() async {
    try {
      FilePickerResult? filesResult = await FilePicker.platform.pickFiles();

      if (filesResult != null &&
          filesResult.count != 0 &&
          filesResult.files[0].path != null) {
        if (filesResult.files[0].extension != "json") {
          showErrorMsg("请选择备份的json文件");
          return;
        }
        Loading.showLoading(context);
        String jsonMap = await File(filesResult.files[0].path!).readAsString();

        await LocalStorage.setAllStorage(jsonMap);
        Loading.hideLoading(context);
        showSuccessMsg("json文件还原完成");
        context.read<ThemeColorProvider>().getThemeColor();
      }
    } catch (e) {
      print(e);
      if (mounted) Loading.hideLoading(context);
      showErrorMsg("json文件还原失败,$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("备份与还原")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              child: Column(
                children: [
                  Text("数据库包含账单,便签,宝贝,健康等数据，备份为db文件"),
                  Text("听书内容和各模块的设置，备份为json文件"),
                  Text("备份目录建议选Documents"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FilledButton(
                onPressed: backup,
                child: const Text("选择备份到的目录"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FilledButton(
                onPressed: restoreDb,
                child: const Text("选择还原的db文件"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FilledButton(
                onPressed: restoreJson,
                child: const Text("选择还原的json文件"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
