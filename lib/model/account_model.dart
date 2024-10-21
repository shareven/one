class AccountModel implements Comparable<AccountModel> {
  int id;
  bool isIncome;
  String costType;
  int money;
  String time;
  String remark;
  AccountModel.fromJson(json)
      : id = json['id'],
        isIncome = json['isIncome'] == 1,
        costType = json['costType'],
        money = json['money'],
        time = json['time'],
        remark = json['remark'];

  @override
  int compareTo(AccountModel other) => id.compareTo(other.id);
}
