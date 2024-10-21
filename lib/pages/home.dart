import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/widgets/animation_heart.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:one/widgets/odsfssgh.dart';

class Home extends StatefulWidget {
  static const String sName = "/home";

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Global.appName),
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: PageView(
          children: [
            const AnimationHeart(),
            Container(),
            const Odsfssgh(),
            
          ],
        ),
      ),
    );
  }
}
