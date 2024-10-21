import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';

class SetSize extends StatefulWidget {
  static const String sName = "/SetSize";

  const SetSize({super.key});
  @override
  State<SetSize> createState() => _SetSizeState();
}

class _SetSizeState extends State<SetSize> {
  double sliderLen = 400;

  /// 身份证的尺寸为：8.56cm×5.4cm×0.1cm
  double sfzLen = 85.6;

  double cm10 = 100;

  bool isSFZ = false;

  String tipSfz = "请滑动到身份证的长度";

  @override
  void initState() {
    super.initState();
    //恢复状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  /// 身份证校准
  setSFZsize() async {
    double mm1 = sliderLen / sfzLen;
    await setMMLen(mm1);
  }

  /// 10cm 校准
  set10CMsize() async {
    double mm1 = sliderLen / cm10;
    await setMMLen(mm1);
  }

  setMMLen(val) async {
    bool? result = await LocalStorage.setMMVal(val);
    if (result == null) {
      showErrorMsg("保存失败");
    } else {
      showSuccessMsg("保存成功");
    }
  }

  clearData() async {
    bool? result = await LocalStorage.clearMMVal();
    if (result == null) {
      showErrorMsg("清除失败");
    } else {
      showSuccessMsg("清除成功");
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxlen = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("校准尺寸"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(children: [
          Column(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  double val = details.delta.dx + sliderLen;
                  val = max(100, val);
                  val = min(val, maxlen);
                  setState(() {
                    sliderLen = val;
                  });
                },
                child: Container(
                    width: maxlen,
                    color: Theme.of(context).secondaryHeaderColor,
                    child: Stack(
                      children: [
                        Positioned(
                          child: Container(
                            width: 1,
                            height: 100,
                            color: Colors.blue,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: sliderLen,
                            height: 100,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  isSFZ ? "请滑动到身份证的长度，点保存" : "请滑动到尺子10厘米的长度，点保存",
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: isSFZ
                    ? FilledButton(
                        onPressed: () => setState(() {
                              isSFZ = false;
                            }),
                        child: const Text("切换到用10cm长度校准"))
                    : FilledButton(
                        onPressed: () => setState(() {
                              isSFZ = true;
                            }),
                        child: const Text("切换到用身份证的长度校准")),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black),
                    onPressed: isSFZ ? setSFZsize : set10CMsize,
                    child: const Text("保存")),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: FilledButton(
                    onPressed: clearData, child: const Text("清除数据")),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
