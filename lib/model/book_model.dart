class BookModel {
  String name;
  String artUrl;
  int start;
  int end;

  // play record
  int playRecordIndex = 1 ;
  int playRecordInSeconds = 0;

  BookModel(
    this.name,
    this.artUrl,
    this.start,
    this.end,
  );

  BookModel.fromJson(json)
      : name = json["name"],
        artUrl = json["artUrl"],
        playRecordIndex = json["playRecordIndex"]??1,
        playRecordInSeconds = json["playRecordInSeconds"]??0,
        start = json["start"],
        end = json["end"];

  toJson() {
    return {
      "name": name,
      "artUrl": artUrl,
      "start": start,
      "end": end,
      "playRecordIndex": playRecordIndex,
      "playRecordInSeconds": playRecordInSeconds,
    };
  }
}
