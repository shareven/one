import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/widgets/animation_heart.dart';

class Nodatafound extends StatelessWidget {
  const Nodatafound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Image.asset(Global.noDataFoundImg),
          const Positioned(
            top: 70.0,
            left: 40.0,
            child: AnimationHeart(),
          )
        ],
      ),
    );
  }
}
