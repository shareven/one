import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/utils/utils.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  static const String sName = "/About";

  const About({super.key});
  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  List<String>? list;
  bool isSfff = false;
  String valdk = "6173736574732F66696C65732F475F32303234313031395F313931303230";

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    List resList = await getloisjd(valdk);
    setState(() {
      list = resList[0];
      isSfff = resList[1];
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(Global.githubUrl))) {
      throw Exception('Could not launch ${Global.githubUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Github开源地址",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: _launchUrl,
                  child: Text(Global.githubUrl),
                ),
                Text(
                    "这是一款免费、开源、不联网的app，可以一定程度保护使用者的隐私安全。做了个隐藏小游戏，可以不看源码来体验。如有问题，请在github提Issue交流。"),
              ],
            ),
          ),
          isSfff
              ? Positioned(
                  bottom: 10,
                  left: 28,
                  child: GestureDetector(
                      onTap: () => awdfadfadf(context, valdk, list, getData),
                      child: Text(
                        hexToString("31E6989FE79083"),
                        style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 4),
                      )))
              : Container()
        ],
      ),
    );
  }
}
