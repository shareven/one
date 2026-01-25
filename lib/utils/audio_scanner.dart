import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/local_storage.dart';
import 'package:one/utils/utils.dart';
import 'package:path/path.dart' as path_lib;
import 'package:permission_handler/permission_handler.dart';

class AudioScanner {
  static const supportedExtensions = [
    '.mp3',
    '.m4a',
    '.mp4',
    '.aac',
    '.flac',
    '.ogg',
    '.wav',
    '.wma',
  ];

  static bool isAudioFile(String path) {
    return supportedExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  static bool isImageFile(String path) {
    String lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  static Future<int> _getAndroidVersion() async {
    try {
      final process = await Process.run('getprop', [
        'ro.build.version.release',
      ]);
      return int.parse(process.stdout.toString().trim());
    } catch (e) {
      return 11;
    }
  }

  static Future<bool> _checkPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidVersion = await _getAndroidVersion();

    bool hasPermission = false;
    if (androidVersion >= 33) {
      hasPermission = await Permission.audio.status.isGranted;
      if (!hasPermission) {
        await Permission.audio.request();
        hasPermission = await Permission.audio.status.isGranted;
      }
    } else {
      hasPermission = await Permission.storage.status.isGranted;
      if (!hasPermission) {
        await Permission.storage.request();
        hasPermission = await Permission.storage.status.isGranted;
      }
    }

    if (!hasPermission) {
      await Permission.manageExternalStorage.request();
      hasPermission = await Permission.manageExternalStorage.status.isGranted;
    }

    return hasPermission;
  }

  static Future<List<BookModel>> scanBooksDirectory(String? customPath) async {
    String basePath = customPath ?? await LocalStorage.getLocalBookDirectory();

    bool hasPermission = await _checkPermissions();
    if (!hasPermission) {
      showErrorMsg("没有存储权限");
      return [];
    }

    return await compute(_scanBooksDirectoryBackground, basePath);
  }

  static Future<List<BookModel>> _scanBooksDirectoryBackground(
    String basePath,
  ) async {
    List<BookModel> books = [];

    try {
      Directory baseDir = Directory(basePath);
      if (!baseDir.existsSync()) {
        return [];
      }

      List<FileSystemEntity> baseEntities = baseDir.listSync();

      for (var entity in baseEntities) {
        if (entity is Directory) {
          String bookName = path_lib.basename(entity.path);

          try {
            List<File> audioFiles = _scanDirectorySync(entity.path);

            if (audioFiles.isNotEmpty) {
              String coverPath = _getBookCoverSync(entity.path, bookName);
              String artUrl = coverPath.isNotEmpty
                  ? coverPath
                  : _generateRandomColorCover(bookName);

              List<AudioTrack> tracks = _extractMetadataListSync(audioFiles);
              books.add(
                BookModel(name: bookName, artUrl: artUrl, tracks: tracks),
              );
            }
          } catch (e) {
            print("扫描书籍 $bookName 失败: $e");
          }
        }
      }
    } catch (e) {
      print("扫描目录失败: $e");
    }

    return books;
  }

  static List<File> _scanDirectorySync(String directoryPath) {
    List<File> audioFiles = [];
    try {
      final dir = Directory(directoryPath);
      if (!dir.existsSync()) return [];

      final entities = dir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File && isAudioFile(entity.path)) {
          audioFiles.add(entity);
        }
      }
    } catch (e) {
      print("_scanDirectorySync 异常: $e");
    }
    return audioFiles;
  }

  static String _getBookCoverSync(String directoryPath, String bookName) {
    try {
      Directory dir = Directory(directoryPath);
      if (!dir.existsSync()) return '';

      for (final entity in dir.listSync()) {
        if (entity is File && isImageFile(entity.path)) {
          return entity.path;
        }
      }

      List<File> audioFiles = _scanDirectorySync(directoryPath);
      if (audioFiles.isNotEmpty) {
        return _generateCoverImageSync(directoryPath, audioFiles[0]);
      }
    } catch (e) {
      print("_getBookCoverSync 异常: $e");
    }
    return '';
  }

  static String _generateCoverImageSync(
    String directoryPath,
    File firstAudioFile,
  ) {
    try {
      dynamic metadata = readMetadata(firstAudioFile, getImage: true);
      if (metadata.picture != null && metadata.picture.isNotEmpty) {
        Uint8List imageData = metadata.picture[0].data;
        String coverPath = path_lib.join(directoryPath, 'cover.jpg');
        File(coverPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(imageData);
        return coverPath;
      }
    } catch (e) {
      print("提取内嵌封面失败: $e");
    }
    return '';
  }

  static String _generateRandomColorCover(String bookName) {
    int hash = bookName.hashCode.abs();
    int r = (hash >> 16) & 0xFF;
    int g = (hash >> 8) & 0xFF;
    int b = hash & 0xFF;
    return 'color:$r,$g,$b';
  }

  static List<AudioTrack> _extractMetadataListSync(List<File> files) {
    List<AudioTrack> tracks = [];
    for (File file in files) {
      try {
        dynamic metadata = readMetadata(file, getImage: false);

        String title = metadata.title ?? file.path.split('/').last;
        String artist = metadata.artist ?? '';
        String album = metadata.album ?? '';
        int trackNumber = metadata.trackNumber ?? 0;
        Duration duration = metadata.duration ?? Duration.zero;

        tracks.add(
          AudioTrack(
            filePath: file.path,
            title: title,
            artist: artist,
            album: album,
            trackNumber: trackNumber,
            duration: duration,
          ),
        );
      } catch (e) {
        print("读取元数据失败 ${file.path}: $e");
        tracks.add(
          AudioTrack(filePath: file.path, title: file.path.split('/').last),
        );
      }
    }
    return _sortTracks(tracks);
  }

  static List<AudioTrack> _sortTracks(List<AudioTrack> tracks) {
    List<AudioTrack> sorted = List.from(tracks);

    sorted.sort((a, b) {
      if (a.trackNumber > 0 && b.trackNumber > 0) {
        return a.trackNumber.compareTo(b.trackNumber);
      }

      String aTitle = a.title.toLowerCase();
      String bTitle = b.title.toLowerCase();

      int numComparison = _extractFirstNumber(
        aTitle,
      ).compareTo(_extractFirstNumber(bTitle));
      if (numComparison != 0) return numComparison;

      return aTitle.compareTo(bTitle);
    });

    return sorted;
  }

  static int _extractFirstNumber(String str) {
    RegExp exp = RegExp(r'\d+');
    Match? match = exp.firstMatch(str);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '0') ?? 0;
    }
    return 0;
  }
}
