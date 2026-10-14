import 'package:flutter/material.dart';

/// 文本超长时自动横向滚动展示完整内容，未超长时正常显示
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration pauseDuration;

  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.pauseDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final ScrollController _controller = ScrollController();
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scheduleLoop();
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
      _scheduleLoop();
    }
  }

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    super.dispose();
  }

  void _scheduleLoop() {
    final gen = ++_generation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runLoop(gen));
  }

  Future<void> _runLoop(int gen) async {
    await Future<void>.delayed(widget.pauseDuration);
    while (mounted && gen == _generation && _controller.hasClients) {
      final maxExtent = _controller.position.maxScrollExtent;
      if (maxExtent <= 0) break;
      final duration = Duration(
        milliseconds: (maxExtent * 60).round().clamp(1000, 20000),
      );
      // 单方向滚动到末尾，停顿后直接跳回开头，再循环
      await _controller.animateTo(
        maxExtent,
        duration: duration,
        curve: Curves.easeInOut,
      );
      if (!mounted || gen != _generation) return;
      await Future<void>.delayed(widget.pauseDuration);
      if (!mounted || gen != _generation) return;
      _controller.jumpTo(0);
      await Future<void>.delayed(widget.pauseDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget child = Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: 1,
          softWrap: false,
        );
        // 文字较短时在可视区域内对齐（如居中），较长时撑开宽度以支持滚动
        if (constraints.maxWidth.isFinite) {
          child = ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: child,
          );
        }
        return SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: child,
        );
      },
    );
  }
}
