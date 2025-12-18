import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:one/utils/local_storage.dart';
import 'package:overlay_support/overlay_support.dart';

/// [Show error msg]
void showErrorMsg(String msg) {
  showSimpleNotification(
    Text(
      msg,
      style: const TextStyle(color: Colors.white),
    ),
    leading: const Icon(
      Icons.error,
      color: Colors.white,
    ),
    duration: const Duration(seconds: 3),
    position: NotificationPosition.bottom,
    background: Colors.red,
  );
}

/// [Show success msg]
void showSuccessMsg(String msg) {
  showSimpleNotification(
    Text(
      msg,
      style: const TextStyle(color: Colors.white),
    ),
    leading: const Icon(
      Icons.check,
      color: Colors.white,
    ),
    position: NotificationPosition.bottom,
    background: Colors.green,
  );
}

showDeleteDialog(BuildContext context, String text,
    {required Function deleteFn, Function? cancelFn}) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            content: Text(
              text,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("取消", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  if (cancelFn != null) cancelFn();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text("删除", style: TextStyle(color: Colors.pink)),
                onPressed: () {
                  deleteFn();
                  Navigator.pop(context);
                },
              ),
            ],
          ));
}

String stringToHex(String str) {
  // 将字符串编码为UTF-8字节数组
  Uint8List bytes = utf8.encode(str);

  // 创建一个StringBuffer来存储16进制字符串
  StringBuffer hexStringBuffer = StringBuffer();

  // 遍历字节数组，将每个字节转换为16进制字符串并追加到hexStringBuffer中
  for (int byte in bytes) {
    // 将字节转换为两位数的16进制字符串，不足两位时在前面补0
    String hexString = byte.toRadixString(16).padLeft(2, '0').toUpperCase();
    hexStringBuffer.write(hexString);
  }

  // 返回最终的16进制字符串
  return hexStringBuffer.toString();
}

String hexToString(String hexString) {
  // 检查16进制字符串长度是否为偶数
  if (hexString.length % 2 != 0) {
    throw ArgumentError('Invalid hex string length');
  }

  // 将16进制字符串转换为字节数组
  Uint8List bytes = Uint8List(hexString.length ~/ 2);
  for (int i = 0; i < hexString.length; i += 2) {
    bytes[i ~/ 2] = int.parse(hexString.substring(i, i + 2), radix: 16);
  }

  // 将字节数组解码为字符串（这里使用UTF-8编码）
  return utf8.decode(bytes);
}

Future<List> getsdecaa(String valdk, int count) async {
  List<String>? res = await LocalStorage.getCasfaf();
  bool sddgfdgsd = count > 4;
  if (res != null && res.isNotEmpty && res.indexOf(valdk) != -1) {
    sddgfdgsd = false;
  }
  return [res, sddgfdgsd];
}

Future<List> getsrhjg(String valdk, int count) async {
  List<String>? res = await LocalStorage.getCasfaf();
  bool sddgfdgsd = count > 10;
  if (res != null && res.isNotEmpty && res.indexOf(valdk) != -1) {
    sddgfdgsd = false;
  }
  return [res, sddgfdgsd];
}

Future<List> getsccww(String valdk, int count) async {
  List<String>? res = await LocalStorage.getCasfaf();
  bool sddgfdgsd = count > 180;
  if (res != null && res.isNotEmpty && res.indexOf(valdk) != -1) {
    sddgfdgsd = false;
  }
  return [res, sddgfdgsd];
}

Future<List> getloisjd(String valdk) async {
  List<String>? res = await LocalStorage.getCasfaf();
  bool sddgfdgsd = true;
  if (res != null && res.isNotEmpty && res.indexOf(valdk) != -1) {
    sddgfdgsd = false;
  }
  return [res, sddgfdgsd];
}

awdfadfadf(BuildContext context, String val, List<String>? list,
    Function? callback) async {
  if (list == null) {
    list = [val];
  } else {
    list.add(val);
  }
  list = list.toSet().toList();
  await LocalStorage.setCasfaf(list);
  if (callback != null) callback();
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hexToString(
                  'E681ADE5969CE4BDA0E88EB7E5BE97E4BBA5E4B88BE789A9E59381EFBC8CE58FAFE59CA8E5B7A5E585B72DE8838CE58C85E69FA5E79C8B'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: 40,
            ),
            Image.asset(hexToString(val))
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(hexToString("E7A1AEE5AE9A"),
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Color lighten(Color color, double factor) {
  assert(factor >= 0 && factor <= 1);
  return Color.lerp(color, Colors.white, factor)!;
}