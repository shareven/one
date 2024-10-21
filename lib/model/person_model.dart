import 'package:intl/intl.dart';

class PersonModel {
  int id;
  String name;
  String updatedAt;
  PersonModel.fromJson(json)
      : id = json['id'],
        name = json['name'],
        updatedAt = DateFormat("yyyy-MM-dd HH:mm:ss").format(
            DateTime.parse("${json['updatedAt'].substring(0, 19)}-0801"));
}
