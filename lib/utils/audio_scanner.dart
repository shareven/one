import 'dart:io';
import 'dart:typed_data';
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
      final process = await Process.run('getprop', ['ro.build.version.release']);
      return int.parse(process.stdout.toString().trim());
    } catch (e) {
      return 11;
    }
  }

  static Future<List<FileSystemEntity>> listDirectories(String path) async {
    try {
      Directory dir = Directory(path);
      if (!await dir.exists()) {
        return [];
      }
      return await dir.list().toList();
    } catch (e) {
      print("listDirectories 异常: $e");
      return [];
    }
  }

  static Future<List<File>> scanDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (!dir.existsSync()) {
        print("目录不存在: $directoryPath");
        return [];
      }

      List<File> audioFiles = [];

      try {
        final entities = dir.listSync(recursive: true);
        print("使用 listSync 找到 ${entities.length} 个实体");

        for (final entity in entities) {
          if (entity is File) {
            final path = entity.path;
            if (isAudioFile(path)) {
              audioFiles.add(entity);
            }
          }
        }
      } catch (e) {
        print("listSync 异常: $e");
        print("尝试使用 MediaStore 扫描...");
        audioFiles = await _scanWithMediaStore(directoryPath);
      }

      print("扫描目录: $directoryPath, 找到 ${audioFiles.length} 个音频文件");
      return audioFiles;
    } catch (e) {
      print("扫描目录失败: $e");
      return [];
    }
  }

  static Future<List<File>> _scanWithMediaStore(String directoryPath) async {
    List<File> audioFiles = [];
    if (!Platform.isAndroid) return [];

    try {
      Directory dir = Directory(directoryPath);
      if (!dir.existsSync()) return [];

      String bookName = path_lib.basename(directoryPath);

      print("MediaStore 扫描目录: $directoryPath (书籍: $bookName)");

      final parentDir = dir.parent;
      if (!parentDir.existsSync()) return [];

      for (final entity in parentDir.listSync()) {
        if (entity is Directory) {
          String dirName = path_lib.basename(entity.path);
          if (dirName == bookName) {
            print("扫描子目录: ${entity.path}");
            List<File> files = await _scanSingleDir(entity.path);
            audioFiles.addAll(files);
          }
        }
      }
    } catch (e) {
      print("MediaStore 扫描失败: $e");
    }
    return audioFiles;
  }

  static Future<List<File>> _scanSingleDir(String dirPath) async {
    List<File> audioFiles = [];
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return [];

      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && isAudioFile(entity.path)) {
          audioFiles.add(entity);
        }
      }
    } catch (e) {
      print("_scanSingleDir 失败: $e");
    }
    return audioFiles;
  }

  static Future<List<BookModel>> scanBooksDirectory(String? customPath) async {
    String basePath = customPath ?? await LocalStorage.getLocalBookDirectory();
    print("=== 开始扫描听书目录 ===");
    print("basePath: $basePath");

    final androidVersion = await _getAndroidVersion();
    print("Android 版本: $androidVersion");

    bool hasPermission = false;
    if (Platform.isAndroid) {
      if (androidVersion >= 33) {
        hasPermission = await Permission.audio.status.isGranted;
      } else {
        hasPermission = await Permission.storage.status.isGranted;
      }
      if (!hasPermission) {
        print("请求存储权限...");
        if (androidVersion >= 33) {
          await Permission.audio.request();
          hasPermission = await Permission.audio.status.isGranted;
        } else {
          await Permission.storage.request();
          hasPermission = await Permission.storage.status.isGranted;
        }
        
        if (!hasPermission) {
             print("尝试请求所有文件访问权限...");
             await Permission.manageExternalStorage.request();
             hasPermission = await Permission.manageExternalStorage.status.isGranted;
        }

        await Future.delayed(Duration(seconds: 1));
      } else {
        // Double check manage storage for Android 11+ just in case file listing is acting up
        if (androidVersion >= 30) {
            if (!await Permission.manageExternalStorage.status.isGranted) {
                 // Don't force it if we already have "audio", but "audio" might not be enough for raw File iteration recursively
                 // For now, let's rely on the fallback above.
            }
        }
      }
    } else {
      hasPermission = true;
    }
    print("存储权限: $hasPermission");

    Directory baseDir = Directory(basePath);
    if (!baseDir.existsSync()) {
      print("听书目录不存在: $basePath");
      showErrorMsg("听书目录不存在: $basePath");
      return [];
    }

    print("开始扫描基础目录...");
    List<FileSystemEntity> baseEntities = [];
    try {
      baseEntities = baseDir.listSync();
    } catch (e) {
      print("基础目录扫描异常: $e");
    }
    print("基础目录找到 ${baseEntities.length} 个实体");

    List<BookModel> books = [];

    for (var entity in baseEntities) {
      if (entity is Directory) {
        String bookName = path_lib.basename(entity.path);
        print("扫描书籍文件夹: $bookName");

        List<File> audioFiles = await scanDirectory(entity.path);
        print("$bookName 找到 ${audioFiles.length} 个音频文件");

        if (audioFiles.isNotEmpty) {
          String coverPath = await _getBookCover(entity.path, bookName);
          String artUrl = coverPath.isNotEmpty
              ? coverPath
              : _generateRandomColorCover(bookName);

          List<AudioTrack> tracks = await extractMetadataList(audioFiles);
          books.add(BookModel(name: bookName, artUrl: artUrl, tracks: tracks));
        }
      }
    }

    print("=== 扫描完成，找到 ${books.length} 本书 ===");
    return books;
  }

  static Future<String> _getBookCover(String directoryPath, String bookName) async {
    try {
      Directory dir = Directory(directoryPath);
      if (!dir.existsSync()) return '';

      for (final entity in dir.listSync()) {
        if (entity is File && isImageFile(entity.path)) {
          return entity.path;
        }
      }

      List<File> audioFiles = await scanDirectory(directoryPath);
      if (audioFiles.isNotEmpty) {
        return await _generateCoverImage(directoryPath, audioFiles[0]);
      }
    } catch (e) {
      print("_getBookCover 异常: $e");
    }
    return '';
  }

  static Future<String> _generateCoverImage(String directoryPath, File firstAudioFile) async {
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

  static Future<AudioTrack> extractMetadata(File file, {bool getImage = false}) async {
    try {
      dynamic metadata = readMetadata(file, getImage: getImage);

      String title = metadata.title ?? file.path.split('/').last;
      String artist = metadata.artist ?? '';
      String album = metadata.album ?? '';
      int trackNumber = metadata.trackNumber ?? 0;
      Duration duration = metadata.duration ?? Duration.zero;

      return AudioTrack(
        filePath: file.path,
        title: title,
        artist: artist,
        album: album,
        trackNumber: trackNumber,
        duration: duration,
      );
    } catch (e) {
      print("读取元数据失败 ${file.path}: $e");
      return AudioTrack(filePath: file.path, title: file.path.split('/').last);
    }
  }

  static Future<List<AudioTrack>> extractMetadataList(List<File> files) async {
    List<AudioTrack> tracks = [];
    for (File file in files) {
      tracks.add(await extractMetadata(file));
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

      int numComparison = _extractFirstNumber(aTitle).compareTo(_extractFirstNumber(bTitle));
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

  static Future<BookModel?> createBookFromDirectory(
    String directoryPath,
    String bookName,
    String artUrl,
  ) async {
    List<File> files = await scanDirectory(directoryPath);
    if (files.isEmpty) {
      showErrorMsg("未找到音频文件");
      return null;
    }

    List<AudioTrack> tracks = await extractMetadataList(files);
    return BookModel(name: bookName, artUrl: artUrl, tracks: tracks);
  }
}

