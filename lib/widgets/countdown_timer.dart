import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final Duration timeLeft;
  const CountdownTimer(this.timeLeft, {super.key});
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  final StreamController<int> _timerController = StreamController<int>();
  Timer? _timer;
  int _timeLeft = 0; // 初始倒计时时间，单位为秒

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeLeft.inSeconds;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        _timerController.add(_timeLeft);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerController.stream,
      initialData: _timeLeft,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int timeLeft = snapshot.data!;
          int minutes = timeLeft ~/ 60;
          int seconds = timeLeft % 60;
          return Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 14),
          );
        } else {
          return const Text("");
        }
      },
    );
  }
}
