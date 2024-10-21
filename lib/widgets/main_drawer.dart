import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:one/pages/about.dart';
import 'package:one/provide/authorize_provide.dart';
import 'package:one/utils/navigator_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  TextEditingController _headText1Controller = TextEditingController(text: "");
  TextEditingController _headText2Controller = TextEditingController(text: "");
  String? _version;
  String? _headImg;
  String? _headText1;
  String? _headText2;
  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String? headImg = await LocalStorage.getHeadImg();
    String headText = await LocalStorage.getHeadText();
    setState(() {
      _version = packageInfo.version;
      _headImg = headImg;
      _headText1 = headText.split("&&&&")[0];
      _headText2 = headText.split("&&&&")[1];
    });
  }

  Future _seletctHeadImg() async {
    FilePickerResult? res =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.count != 0 && res.files[0].path != null) {
      String heaImg = res.files[0].path!;
      await LocalStorage.setHeadImg(heaImg);
      setState(() {
        _headImg = heaImg;
      });
    }
  }

  _save() async {
    String val = _headText1Controller.text + "&&&&" + _headText2Controller.text;
    await LocalStorage.setHeadText(val);
    setState(() {
      _headText1 = _headText1Controller.text;
      _headText2 = _headText2Controller.text;
    });
  }

  _setHeadText() async {
    _headText1Controller.text = _headText1 ?? "";
    _headText2Controller.text = _headText2 ?? "";

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  maxLength: 32,
                  controller: _headText1Controller,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  maxLength: 32,
                  controller: _headText2Controller,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("取消", style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("保存", style: TextStyle(color: Colors.pink)),
            onPressed: () {
              _save();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authorized = context.watch<AuthorizeProvide>().authorized;

    Widget updateWidet = ListTile(
      leading: const Icon(
        Icons.help,
        color: Colors.grey,
      ),
      onLongPress: deasl,
      title: Text("版本:$_version"),
    );
    if (_version == null || _headText1 == null) {
      return Drawer();
    }
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: GestureDetector(
                onTap: _setHeadText, child: Text(_headText1 ?? "")),
            accountEmail: GestureDetector(
                onTap: _setHeadText, child: Text(_headText2 ?? "")),
            currentAccountPicture: GestureDetector(
              onTap: _seletctHeadImg,
              child: _headImg != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(_headImg!)),
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).disabledColor,
                    ),
            ),
            decoration: _headImg != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(_headImg!)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          BlendMode.dstATop),
                    ),
                  )
                : null,
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(
                          Icons.home,
                          color: Colors.lightBlue,
                        ),
                        title: const Text("首页"),
                        onTap: () {
                          NavigatorUtil.goHome(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.brown,
                        ),
                        title: const Text("听书"),
                        onTap: () {
                          NavigatorUtil.goAudio(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.pie_chart,
                          color: Colors.teal,
                        ),
                        title: const Text("账单"),
                        onTap: () {
                          if (authorized) {
                            NavigatorUtil.goAccounts(context);
                          } else {
                            NavigatorUtil.goAuthorize(context);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.note,
                          color: Colors.cyan,
                        ),
                        title: const Text("便签"),
                        onTap: () {
                          NavigatorUtil.goNotes(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.local_drink,
                          color: Colors.pinkAccent,
                        ),
                        title: const Text("宝贝"),
                        onTap: () {
                          NavigatorUtil.goBaby(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.run_circle_rounded,
                          color: Colors.green,
                        ),
                        title: const Text("健康"),
                        onTap: () {
                          NavigatorUtil.goHealth(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.store_mall_directory_rounded,
                          color: Colors.deepOrange,
                        ),
                        title: const Text("工具"),
                        onTap: () {
                          NavigatorUtil.goTools(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings,
                            color: Colors.deepPurple),
                        title: const Text("设置"),
                        onTap: () {
                          NavigatorUtil.goSetting(context);
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.info, color: Colors.orangeAccent),
                        title: const Text("关于"),
                        onTap: () {
                          Navigator.pushNamed(context, About.sName);
                        },
                      ),
                      updateWidet,
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void deasl() async {
    String ue3ww =
        "6173736574732F66696C65732F475F32303234313031395F313931313133";
    List resList1 = await getloisjd(ue3ww);
    if (resList1[1]) {
      awdfadfadf(context, ue3ww, resList1[0], null);
    }
  }
}
