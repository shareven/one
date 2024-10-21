

class HealthModel implements Comparable<HealthModel>{
  int id;

  /// 体重
  double weight;

  /// 身高
  double height;

  /// person
  String person;

  /// 体重身高指数 体质指数(BMI)=体重(kg)/身高 (m)^2 　EX:75/(1.8^2)=23.15
  double bmi;
  String time;
  HealthModel.fromJson(json)
      : id = json['id'],
        weight = double.parse(json['weight'].toString()),
        height = double.parse(json['height'].toString()),
        bmi = double.parse(json['bmi'].toString()),
        person=json["person"],
        time=json['time'];

         @override
  int compareTo(HealthModel other) => time.compareTo(other.time);
}
