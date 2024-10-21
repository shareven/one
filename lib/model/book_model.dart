class BookModel {
  String name;
  String artUrl;
  int start;
  int end;

  BookModel(
    this.name,
    this.artUrl,
    this.start,
    this.end,
  );

  BookModel.fromJson(json)
      : name = json["name"],
        artUrl = json["artUrl"],
        start = json["start"],
        end = json["end"];

  toJson() {
    return {
      "name": name,
      "artUrl": artUrl,
      "start": start,
      "end": end,
    };
  }
}
