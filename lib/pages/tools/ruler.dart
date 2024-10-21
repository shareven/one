import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one/pages/tools/set_size.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';

class Ruler extends StatefulWidget {
  static const String sName = "/Ruler";

  const Ruler({super.key});
  @override
  State<Ruler> createState() => _RulerState();
}

class _RulerState extends State<Ruler> {
  double mm1 = 10;
  bool isNeedAdjust = false;

  @override
  void initState() {
    super.initState();
    getMMLen();
    //强制横屏
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    //隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  getMMLen() async {
    String? mm = await LocalStorage.getMMVal();
    if (mm == null) {
      showErrorMsg("请先校准尺寸");
      setState(() {
        isNeedAdjust = true;
      });
    } else {
      setState(() {
        mm1 = double.parse(mm);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxlen = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 0.0),
        child: Column(
          children: [
            RulerWidget(
              mm1: mm1,
              maxLen: maxlen,
            ),
            isNeedAdjust
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const Text("首次使用，请先校准尺寸"))
                : Container(),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: FilledButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => const SetSize()));
                  getMMLen();
                  //隐藏状态栏
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: []);
                },
                child: const Text("校准尺寸"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RulerWidget extends StatefulWidget {
  const RulerWidget({super.key, required this.mm1, required this.maxLen});

  /// the 1mm size
  final double mm1;

  /// the max size
  final double maxLen;

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget> {
  /// widget of mm
  Widget mMWidget() {
    int numMM = widget.maxLen ~/ widget.mm1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        numMM,
        (index) => Container(
          margin: EdgeInsets.only(right: widget.mm1 - 1),
          width: 1,
          height: index % 5 == 0 ? 28 : 20,
          color: index == 100 ? Colors.black : Colors.black26,
        ),
      ),
    );
  }

  /// widget of cm
  Widget cMWidget() {
    double cmLen = widget.mm1 * 10;
    int numCM = (widget.maxLen ~/ cmLen) + 1;
    return Column(
      children: [
        Row(
          children: List.generate(
            numCM,
            (index) => Container(
              margin: EdgeInsets.only(
                  bottom: 5, right: numCM - 1 == index ? 0 : cmLen - 1),
              width: 1,
              height: 15,
              color: index == 10 ? Colors.black : Colors.black26,
            ),
          ),
        ),
        SizedBox(
          height: 30,
          child: Stack(
            children: List.generate(
                numCM,
                (index) => Positioned(
                      left: (cmLen * index),
                      child: Text(
                        index.toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                    )),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      width: widget.maxLen,
      height: 150,
      child: Column(children: [
        mMWidget(),
        cMWidget(),
      ]),
    );
  }
}
