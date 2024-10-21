import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one/pages/tools/ruler.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/fsgsfdgd.dart';
import 'package:one/widgets/main_drawer.dart';

class Tools extends StatefulWidget {
  static const String sName = "/Tools";

  const Tools({super.key});
  @override
  State<Tools> createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  List<String>? _list;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    List<String>? list = await LocalStorage.getCasfaf();
    setState(() {
      _list = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("工具"),
        actions: _list != null && _list!.length < 8
            ? [
                TextButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Fsgsfdgd(),
                          ),
                        ),
                    child: Text(
                      hexToString("E8838CE58C85"),
                      style: TextStyle(color: Colors.white),
                    ))
              ]
            : null,
      ),
      drawer: const MainDrawer(),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.dns_sharp),
            title: const Text('直尺'),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const Ruler()));
              //强制竖屏
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ]);

              //恢复状态栏
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: SystemUiOverlay.values);
            },
          ),
        ],
      ),
    );
  }
}
