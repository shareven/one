
class BabyModel implements Comparable<BabyModel> {
  int id;
  String option;
  String startTime;
  String? endTime;
  BabyModel.fromJson(json)
      : id = json['id'],
        option = json['option'],
        startTime = json['startTime'],
        endTime = json['endTime'];
 
  @override
  int compareTo(BabyModel other) => startTime.compareTo(other.startTime);
}
