import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:one/provider/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:one/config/global.dart';
import 'package:one/model/book_model.dart';
import 'package:one/pages/audio/books.dart';
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
  double itemHeight = 50.0;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecord();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioProvider = context.read<AudioProvider>();
  }

  @override
  void dispose() {
    _audioProvider?.setOnPlayStateRestored(null);
    super.dispose();
  }

  void scrollToItem(int index) {
    
    double scrollPosition = index * itemHeight;
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 30),
      curve: Curves.easeOut,
    );
  }

  Color _parseColor(String colorStr) {
    if (colorStr.startsWith('color:')) {
      List<String> parts = colorStr.substring(6).split(',');
      if (parts.length == 3) {
        return Color.fromRGBO(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          1.0,
        );
      }
    }
    return Colors.grey;
  }

  Widget _buildCoverImage(dynamic artUrl) {
    String? artUrlPath;

    if (artUrl == null) {
      artUrlPath = null;
    } else if (artUrl is Uri) {
      if (artUrl.scheme == 'color') {
        artUrlPath = artUrl.toString();
      } else {
        artUrlPath = artUrl.path;
      }
    } else if (artUrl is String) {
      artUrlPath = artUrl;
    } else {
      artUrlPath = artUrl.toString();
    }

    if (artUrlPath == null || artUrlPath.isEmpty) {
      return Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.book,
          size: 60,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (artUrlPath.startsWith('color:')) {
      return Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: _parseColor(artUrlPath),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.book, size: 60, color: Colors.white),
      );
    }

    File coverFile = File(artUrlPath);
    if (!coverFile.existsSync()) {
      return Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.book,
          size: 60,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: FileImage(coverFile), fit: BoxFit.cover),
      ),
    );
  }

  Future getRecord() async {
    BookModel? res = await LocalStorage.getCurrentBookVal();
    if (res != null) {
      try {
        if (player.currentIndex != null && player.sequence.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            if (mounted) {
              scrollToItem(player.currentIndex!);
            }
          });
        } else {
          context.read<AudioProvider>().setOnPlayStateRestored(() {
            if (mounted) {
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
            child: ListView(
              shrinkWrap: true,
              children: Global.closeTimeList.map((e) {
                if (e == 0) {
                  return ListTile(
                    title: Text(
                      "不开启",
                      style: TextStyle(
                        fontWeight: closeTime == e
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
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
                          : FontWeight.normal,
                    ),
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
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    context.read<AudioProvider>().audioInit();
    bool isGetRecord = context.watch<AudioProvider>().isGetRecord;
    int closeTime = context.select((AudioProvider a) => a.closeTime);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text("听书"),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            color: closeTime == 0 ? null : colorScheme.secondary,
            onPressed: () => setCloseTime(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingBook()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Books()),
              );
              getRecord();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.headphones,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "没有播放内容",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: _buildCoverImage(
                            metadata.extras?['artUrl'] ?? metadata.artUri,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          isInit && isGetRecord ? metadata.title : "",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          isInit && isGetRecord ? metadata.album ?? "" : "",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 12,color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
            isInit && isGetRecord
                ? ControlButtons(player)
                : const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
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
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: StreamBuilder<SequenceState?>(
                  stream: player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final sequence = state?.sequence ?? [];
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: sequence.length,
                      itemBuilder: (context, index) {
                        final isCurrent = index == state?.currentIndex;
                        return Container(
                          height: itemHeight,
                          color: isCurrent
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          child: ListTile(
                            title: Text(
                              sequence[index].tag.title as String,
                              style: TextStyle(
                                color: isCurrent
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              await player.seek(Duration.zero, index: index);
                              player.play();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final canRewind = position > const Duration(seconds: 10);
            return IconButton(
              icon: const Icon(Icons.replay_10_rounded),
              iconSize: 44.0,
              onPressed: player.duration != null && canRewind
                  ? () => player.seek(position - const Duration(seconds: 10))
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
              return const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return _buildPlayButton(colorScheme);
            } else if (processingState != ProcessingState.completed) {
              return _buildPauseButton(colorScheme);
            } else {
              return _buildReplayButton(colorScheme);
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
            final position = snapshot.data ?? Duration.zero;
            final duration = player.duration ?? Duration.zero;
            final canForward =
                position < duration - const Duration(seconds: 10);
            return IconButton(
              icon: const Icon(Icons.forward_10_rounded),
              iconSize: 44.0,
              onPressed: duration != Duration.zero && canForward
                  ? () => player.seek(position + const Duration(seconds: 10))
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayButton(ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow, size: 48),
        onPressed: player.play,
        color: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildPauseButton(ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.pause, size: 48),
        onPressed: player.pause,
        color: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildReplayButton(ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.replay, size: 48),
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices.first),
        color: colorScheme.onPrimary,
      ),
    );
  }
}
