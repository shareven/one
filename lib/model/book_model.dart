class AudioTrack {
  final int? id;
  final int? bookId;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int trackNumber;
  final Duration duration;
  final bool isListened;

  AudioTrack({
    this.id,
    this.bookId,
    required this.filePath,
    required this.title,
    this.artist = '',
    this.album = '',
    this.trackNumber = 0,
    this.duration = Duration.zero,
    this.isListened = false,
  });

  AudioTrack.fromJson(Map<String, dynamic> json)
    : id = json["id"] as int?,
      bookId = json["bookId"] as int?,
      filePath = json["filePath"] as String,
      title = json["title"] as String,
      artist = json["artist"] as String? ?? '',
      album = json["album"] as String? ?? '',
      trackNumber = json["trackNumber"] as int? ?? 0,
      duration = Duration(milliseconds: json["duration"] as int? ?? 0),
      isListened = (json["isListened"] is int)
          ? (json["isListened"] == 1)
          : (json["isListened"] as bool? ?? false);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bookId": bookId,
      "filePath": filePath,
      "title": title,
      "artist": artist,
      "album": album,
      "trackNumber": trackNumber,
      "duration": duration.inMilliseconds,
      "isListened": isListened,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "bookId": bookId,
      "filePath": filePath,
      "title": title,
      "artist": artist,
      "album": album,
      "trackNumber": trackNumber,
      "duration": duration.inMilliseconds,
      "isListened": isListened ? 1 : 0,
    };
  }
}

class BookModel {
  int? id;
  String name;
  String artUrl;

  // 旧模式：基于文件名（向后兼容）
  int? start;
  int? end;

  // 新模式：基于文件列表和元数据
  List<AudioTrack>? tracks;

  // play record
  int playRecordIndex = 1;
  int playRecordInSeconds = 0;
  String? updatedAt;

  BookModel({
    this.id,
    required this.name,
    required this.artUrl,
    this.start,
    this.end,
    this.tracks,
    this.playRecordIndex = 1,
    this.playRecordInSeconds = 0,
    this.updatedAt,
  });

  bool get isMetadataMode => tracks != null && tracks!.isNotEmpty;

  int get totalTracks {
    if (isMetadataMode) {
      return tracks!.length;
    }
    return (end != null && start != null) ? (end! - start! + 1) : 0;
  }

  BookModel.fromJson(Map<String, dynamic> json)
    : id = json["id"] as int?,
      name = json["name"] as String,
      artUrl = json["artUrl"] as String,
      start = json["start"] as int?,
      end = json["end"] as int?,
      playRecordIndex = json["playRecordIndex"] as int? ?? 1,
      playRecordInSeconds = json["playRecordInSeconds"] as int? ?? 0,
      updatedAt = json["updatedAt"] as String?,
      tracks = json["tracks"] != null
          ? (json["tracks"] as List)
                .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
                .toList()
          : null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "id": id,
      "name": name,
      "artUrl": artUrl,
      "playRecordIndex": playRecordIndex,
      "playRecordInSeconds": playRecordInSeconds,
      "updatedAt": updatedAt,
    };

    if (isMetadataMode) {
      data["tracks"] = tracks!.map((e) => e.toJson()).toList();
    } else {
      if (start != null) data["start"] = start;
      if (end != null) data["end"] = end;
    }

    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "artUrl": artUrl,
      "playRecordIndex": playRecordIndex,
      "playRecordInSeconds": playRecordInSeconds,
      "updatedAt": updatedAt ?? DateTime.now().toIso8601String(),
    };
  }
}
