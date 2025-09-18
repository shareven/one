import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:one/model/book_model.dart';
import 'package:one/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:one/config/global.dart';
import 'package:one/pages/audio/Books.dart';
import 'package:one/pages/audio/setting_book.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/widgets/countdown_timer.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:one/widgets/seek_bar.dart';

class Audio extends StatefulWidget {
  static const String sName = "/Audio";
  const Audio({super.key});

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  final ScrollController _scrollController = ScrollController();
  bool isInit = false;
  AudioProvider? _audioProvider;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecord();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 保存AudioProvider引用以便在dispose中安全使用
    _audioProvider = context.read<AudioProvider>();
  }

  @override
  void dispose() {
    // 清理回调避免内存泄漏
    _audioProvider?.setOnPlayStateRestored(null);
    super.dispose();
  }

// 滚动到当前集
  void scrollToItem(int index) {
    double itemHeight = 50.0;
    double scrollPosition = index * itemHeight;
    _scrollController.animateTo(scrollPosition,
        duration: const Duration(milliseconds: 30), curve: Curves.easeOut);
  }

  Future getRecord() async {
    BookModel? res = await LocalStorage.getCurrentBookVal();
    if (res != null) {
      try {
        // 检查播放器是否已经有当前播放的内容
        if (player.currentIndex != null && player.sequence.isNotEmpty) {
          // 播放器已经初始化，直接滚动到当前位置
          Future.delayed(Duration.zero, () {
            if (mounted) {
              scrollToItem(player.currentIndex!);
            }
          });
        } else {
          // 播放器还未初始化，设置回调等待初始化完成
          context.read<AudioProvider>().setOnPlayStateRestored(() {
            if (mounted) {
              // 使用Future.delayed确保在下一帧执行，避免在build过程中调用setState
              Future.delayed(Duration.zero, () {
                if (mounted) {
                  scrollToItem(res.playRecordIndex);
                }
              });
            }
          });
        }
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      isInit = true;
    });
  }

  Future<void> setCloseTime(BuildContext context) {
    int closeTime = context.read<AudioProvider>().closeTime;
    DateTime? closeDateTime = context.read<AudioProvider>().closeDateTime;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("定时关闭"),
          content: SizedBox(
            height: 400,
            child: Column(
              children: Global.closeTimeList.map((e) {
                if (e == 0) {
                  return ListTile(
                    title: Text(
                      "不开启",
                      style: TextStyle(
                          fontWeight: closeTime == e
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                    selected: closeTime == e,
                    onTap: () {
                      context.read<AudioProvider>().cancelTimer();
                      Navigator.of(context).pop();
                    },
                  );
                }
                Widget? trailing;
                if (closeTime == e && closeDateTime != null) {
                  Duration duration = closeDateTime.difference(DateTime.now());
                  trailing = CountdownTimer(duration);
                }
                return ListTile(
                  title: Text(
                    "$e分钟",
                    style: TextStyle(
                        fontWeight: closeTime == e
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                  selected: closeTime == e,
                  trailing: trailing,
                  onTap: () {
                    context.read<AudioProvider>().setCloseTime(e);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    // 初始化audio
    context.read<AudioProvider>().audioInit();
    int closeTime = context.select((AudioProvider a) => a.closeTime);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text("听书"),
        actions: [
          IconButton(
              color: closeTime == 0
                  ? null
                  : Theme.of(context).colorScheme.secondary,
              onPressed: () => setCloseTime(context),
              icon: const Icon(Icons.alarm)),
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const SettingBook()));
              },
              icon: const Icon(Icons.settings_applications_sharp)),
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const Books()));
                getRecord();
              },
              icon: const Icon(Icons.book))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    return const SizedBox();
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(metadata.artUri!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(metadata.album!,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(metadata.title),
                    ],
                  );
                },
              ),
            ),
            isInit? ControlButtons(player):Container(
              margin: const EdgeInsets.all(8.0),
              width: 64.0,
              height: 64.0,
              child: const CircularProgressIndicator(),
            ),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    player.seek(newPosition);
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 300.0,
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView(
                    controller: _scrollController,
                    children: [
                      for (var i = 0; i < sequence.length; i++)
                        SizedBox(
                          height: 50,
                          child: Material(
                            color: i == state!.currentIndex
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).highlightColor,
                            child: ListTile(
                              title: Text(sequence[i].tag.title as String),
                              onTap: () async {
                                await player.seek(Duration.zero, index: i);
                                player.play();
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              icon: const Icon(Icons.replay_10_rounded),
              iconSize: 44.0,
              onPressed: player.duration != null
                  ? () => player.seek((positionData ?? Duration.zero) -
                      const Duration(seconds: 10))
                  : null,
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            iconSize: 44.0,
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 44.0,
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              icon: const Icon(Icons.forward_10_rounded),
              iconSize: 44.0,
              onPressed: player.duration != null
                  ? () => player.seek((positionData ?? Duration.zero) +
                      const Duration(seconds: 10))
                  : null,
            );
          },
        ),
      ],
    );
  }
}
