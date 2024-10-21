import 'package:intl/intl.dart';

class BabyoptionModel implements Comparable<BabyoptionModel> {
  int id;
  String name;
  String updatedAt;
  BabyoptionModel.fromJson(json)
      : id = json['id'],
        name = json['name'],

        // updatedAt=DateTime.now().toUtc().toString();
        // updatedAt=DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse("2002-01-27T14:00:00-0500"));
        updatedAt = DateFormat("yyyy-MM-dd HH:mm:ss").format(
            DateTime.parse("${json['updatedAt'].substring(0, 19)}-0801"));
  // updatedAt=DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse("2019-03-01T14:48:28Z"));

  @override
  int compareTo(BabyoptionModel other) => updatedAt.compareTo(other.updatedAt);
}
