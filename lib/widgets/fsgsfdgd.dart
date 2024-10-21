import 'package:flutter/material.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/navigator_util.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/sljdssfdafg.dart';

class Fsgsfdgd extends StatefulWidget {
  const Fsgsfdgd({super.key});

  @override
  State<Fsgsfdgd> createState() => _FsgsfdgdState();
}

class _FsgsfdgdState extends State<Fsgsfdgd> {
  List<String>? _list;
  TextEditingController _textEditingController =
      TextEditingController(text: "");
  List<List<double>> _listPosition = [
    [310, 120],
    [70, 40],
    [130, 210],
    [270, 80],
    [90, 100],
    [160, 70],
    [100, 150],
  ];
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    List<String>? list = await LocalStorage.getCasfaf();
    setState(() {
      _list = list;
    });
  }

  _dsdff() async {
    await Future.delayed(Duration(seconds: 1));

    List<String> list = _list!.toSet().toList();
    list.add(
        "6173736574732F66696C65732F62383161646439323861393134343731393534633835653466306566386432373537663662643930");
    await LocalStorage.setCasfaf(list);
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const Sljdssfdafg(),
      ),
    );
    NavigatorUtil.goAbout(context);
  }

  _handel(v) {
    return hexToString(hexToString(v));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (_list != null && _list!.isNotEmpty && _list!.length < 8) {
      children = _list!
          .asMap()
          .keys
          .map(
            (e) => Positioned(
              left: _listPosition[e][0],
              top: _listPosition[e][1],
              child: Image.asset(hexToString(_list![e]), width: 50, height: 50),
            ),
          )
          .toList();

      if (_list!.length == 7)
        children.add(Positioned(
          left: 0,
          top: 350,
          child: SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _textEditingController,
                    onChanged: (value) {
                      if (value ==
                          _handel("453538374241453639444135453539304137"))
                        _dsdff();
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {}, child: Text(hexToString("E7A59EE9BE99"))),
              ],
            ),
          ),
        ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(hexToString("E8838CE58C85")),
        ),
        body: Stack(
          children: children,
        ));
  }
}
