import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:one/config/global.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';

AudioPlayer player = AudioPlayer();

class AudioProvide with ChangeNotifier {
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  // 0 表示不开启
  int closeTime = 0;
  // 关闭时间
  DateTime? closeDateTime;
  // 创建一个Timer
  Timer? _timer;
  //播放流订阅
  StreamSubscription<Duration>? subscriptionPlayStream;

  // 取消定时关闭任务
  void cancelTimer() {
    closeDateTime = null;
    closeTime = 0;
    // 如果timer不为null，则取消它
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  Future setCloseTime(int val) async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    closeDateTime = DateTime.now().add(Duration(minutes: val));
    _timer = Timer.periodic(Duration(minutes: val), (timer) {
      player.pause();
      cancelTimer();
    });

    closeTime = val;
    notifyListeners();
  }

  Future<List<AudioSource>> _getCurrentBookItems() async {
    BookModel? book = await LocalStorage.getCurrentBookVal();
    String bookLocalPath = await LocalStorage.getLocalBookDirectory();
    if (book != null) {
      List<AudioSource> items = List.generate(
        book.end - book.start + 1,
        (i) {
          int index = book.start + i;
          String str = "第$index集";
          String fileName = "${book.name}$index.m4a";
          return AudioSource.uri(
            Uri.file('$bookLocalPath/${book.name}/$fileName'),
            tag: MediaItem(
              id: '$i',
              album: str,
              title: "${book.name} $str",
              artist: str,
              artUri: Uri.file("${book.artUrl}"),
            ),
          );
        },
      );
      return items;
    }
    return [];
  }

  Future<void> audioInit() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    List<Duration> bookSkipSeconds = await LocalStorage.getPlaySkipSeconds();

    // Listen to errors during playback.
    player.playbackEventStream
        .listen((event) {}, onError: (Object e, StackTrace stackTrace) {});

    // 如果subscriptionPlayStream不为null，则取消它
    if (subscriptionPlayStream != null) {
      await subscriptionPlayStream!.cancel();
    }
    subscriptionPlayStream = player.positionStream.listen((position) {
      //  记录播放位置 3s保存一次 | Record playback position and save once every 3 seconds
      if (player.playing &&
          player.currentIndex != null &&
          position.inSeconds != 0 &&
          position.inSeconds % Global.autoSaveSeconds == 0) {
        LocalStorage.setPlayRecordVal(
            [player.currentIndex, position.inSeconds]);
      }

      if (position.inMilliseconds < bookSkipSeconds[0].inMilliseconds &&
          player.playing) {
        // 刚开始播放时设置跳过片头 | Set to skip the opening when starting playback
        player.seek(bookSkipSeconds[0]);
      }

      // 播到快结束时设置跳过片尾 | Set to skip the ending when the video is almost finished
      if (player.duration != null &&
          position.inMilliseconds >
              player.duration!.inMilliseconds -
                  bookSkipSeconds[1].inMilliseconds) {
        player.seekToNext();
      }
    });
    BookModel? book = await LocalStorage.getCurrentBookVal();
    if (book != null) {
      setPlayBookItems();
    }
    notifyListeners();
  }

  setPlayBookItems() async {
    try {
      // 请求权限 | Permission request
      await Permission.audio.request();

      var status = await Permission.audio.status;

      _setSource();
      if (!status.isGranted) {
        showErrorMsg("音频权限获取失败 | Failed to obtain audio permission");
      }
    } catch (e, stackTrace) {
      print("Error loading playlist: $e");
      print(stackTrace);
    }

    notifyListeners();
  }

  _setSource() async {
    List<AudioSource> list = await _getCurrentBookItems();
    _playlist = ConcatenatingAudioSource(children: list);
    try {
      await player.setAudioSource(_playlist);
    } catch (e) {
      showErrorMsg(e.toString());
    }
    _getRecord();
    notifyListeners();
  }

  _getRecord() async {
    var res = await LocalStorage.getPlayRecordVal();
    if (res != null) {
      await player.seek(Duration(seconds: res[1]), index: res[0]);
    }
  }
}
