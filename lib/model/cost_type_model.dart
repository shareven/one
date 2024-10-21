class CostTypeModel {
  int id;
  String name;
  bool isIncome;
  CostTypeModel(this.id, this.name, this.isIncome);
  CostTypeModel.fromJson(json)
      : id = json['id'] ?? '000',
        name = json['name'] ?? '',
        isIncome = json['isIncome'] == 1;
}
