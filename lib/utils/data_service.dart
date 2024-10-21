import 'dart:convert';

import 'package:one/utils/database_helper.dart';
import 'package:one/utils/result_data.dart';
import 'package:one/utils/utils.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DataService {
  static Future<ResultData> getCostType() async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(DatabaseHelper.costTypeTableName);

      return ResultData(res, 200);
    } catch (e) {}

    return ResultData("err", 111);
  }

  static Future<ResultData> deleteCostType(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.costTypeTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addCostType(Map<String, Object?> data) async {
    try {
      /// sqflite not support bool
      data["isIncome"] = (data["isIncome"] as bool) ? 1 : 0;

      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.costTypeTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getAccountsCount(String whereData) async {
    try {
      Database db = await databaseHelper.database;
      int? count;
      if (whereData.isNotEmpty && whereData != "{}") {
        String? costType;
        String? remark;

        try {
          Map<String, Object?> map = jsonDecode(whereData);
          costType = (map["costType"] as String?);
          remark = (map["remark"] as String?);
        } catch (e) {
          showErrorMsg("getAccountsCount jsonDecode err: " + e.toString());
          return ResultData("jsonDecode err", 111);
        }
        if (costType != null && remark != null) {
          count = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseHelper.accountTableName} WHERE costType = ? AND remark LIKE ?',
            [costType, '%$remark%'],
          ));
        } else if (costType != null) {
          count = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseHelper.accountTableName} WHERE costType = ?',
            [costType],
          ));
        } else if (remark != null) {
          count = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseHelper.accountTableName} WHERE remark LIKE ?',
            ['%$remark%'],
          ));
        }
      } else {
        count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseHelper.accountTableName}',
        ));
      }
      return ResultData({"count": count}, 200);
    } catch (e) {
      print(e);
    }
    return ResultData("err", 111);
  }

  static Future<ResultData> getAccountsAll() async {
    try {
      Database db = await databaseHelper.database;
      var res =
          await db.query(DatabaseHelper.accountTableName, orderBy: "time ASC");

      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getAccountsFilter(
      String whereData, int skipNum, int limit) async {
    try {
      Database db = await databaseHelper.database;
      List resList = [];
      if (whereData.isNotEmpty && whereData != "{}") {
        String? costType;
        String? remark;

        try {
          Map<String, Object?> map = jsonDecode(whereData);
          costType = (map["costType"] as String?);
          remark = (map["remark"] as String?);
        } catch (e) {
          showErrorMsg("getAccountsFilter jsonDecode err: " + e.toString());
          return ResultData("jsonDecode err", 111);
        }
        if (costType != null && remark != null) {
          resList = await db.query(
            DatabaseHelper.accountTableName,
            where: 'costType = ? AND remark LIKE ?',
            whereArgs: [costType, '%$remark%'],
            orderBy: "time DESC",
            limit: limit,
            offset: skipNum,
          );
        } else if (costType != null) {
          resList = await db.query(
            DatabaseHelper.accountTableName,
            where: 'costType = ?',
            whereArgs: [costType],
            orderBy: "time DESC",
            limit: limit,
            offset: skipNum,
          );
        } else if (remark != null) {
          resList = await db.query(
            DatabaseHelper.accountTableName,
            where: 'remark LIKE ?',
            whereArgs: ['%$remark%'],
            orderBy: "time DESC",
            limit: limit,
            offset: skipNum,
          );
        }
      } else {
        resList = await db.query(
          DatabaseHelper.accountTableName,
          orderBy: "time DESC",
          limit: limit,
          offset: skipNum,
        );
      }

      return ResultData(resList, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addAccounts(Map<String, Object?> data) async {
    try {
      /// sqflite not support bool
      data["isIncome"] = (data["isIncome"] as bool) ? 1 : 0;

      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.accountTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> deleteAccounts(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.accountTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addBabyoption(Map<String, Object?> data) async {
    data["updatedAt"] = new DateTime.now().toIso8601String();
    try {
      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.babyoptionTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getBabyoption() async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(DatabaseHelper.babyoptionTableName);
      return ResultData(res, 200);
    } catch (e) {}

    return ResultData("err", 111);
  }

  static Future<ResultData> deleteBabyoption(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.babyoptionTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getBaby() async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(
        DatabaseHelper.babyTableName,
        orderBy: "startTime DESC",
      );
      return ResultData(res, 200);
    } catch (e) {}

    return ResultData("err", 111);
  }

  static Future<ResultData> addBaby(Map<String, Object?> data) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.babyTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> putBaby(id, Map<String, Object?> data) async {
    try {
      Database db = await databaseHelper.database;

      var res = await db.update(DatabaseHelper.babyTableName, data,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> deleteBaby(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.babyTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> deletePerson(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.personTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getPerson() async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(DatabaseHelper.personTableName);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addPerson(Map<String, Object?> data) async {
    data["updatedAt"] = new DateTime.now().toIso8601String();
    try {
      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.personTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addHealth(Map<String, Object?> data) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.healthTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getHealthCount() async {
    try {
      Database db = await databaseHelper.database;
      int? count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseHelper.healthTableName}',
      ));
      return ResultData({"count": count}, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getHealthAll() async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(
        DatabaseHelper.healthTableName,
        orderBy: "time ASC",
      );
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getHealthFilter(int skipNum, int limit) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.query(
        DatabaseHelper.healthTableName,
        orderBy: "time DESC",
        offset: skipNum,
        limit: limit,
      );
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> deleteHealth(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.healthTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> getNoteFilter(String whereData) async {
    try {
      Database db = await databaseHelper.database;
      List resList = [];
      if (whereData.isNotEmpty && whereData != "{}") {
        String? content;

        try {
          Map<String, Object?> map = jsonDecode(whereData);
          content = (map["content"] as String?);
        } catch (e) {
          showErrorMsg("getNoteFilter jsonDecode err: " + e.toString());
          return ResultData("jsonDecode err", 111);
        }
        resList = await db.query(
          DatabaseHelper.notesTableName,
          where: 'content LIKE ?',
          whereArgs: ['%$content%'],
          orderBy: "updatedAt DESC",
        );
      } else {
        resList = await db.query(
          DatabaseHelper.notesTableName,
          orderBy: "updatedAt DESC",
        );
      }
      return ResultData(resList, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> addNote(Map<String, Object?> data) async {
    data["updatedAt"] = new DateTime.now().toIso8601String();
    try {
      Database db = await databaseHelper.database;
      var res = await db.insert(DatabaseHelper.notesTableName, data);
      data["id"] = res;
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> deleteNote(id) async {
    try {
      Database db = await databaseHelper.database;
      var res = await db.delete(DatabaseHelper.notesTableName,
          where: "id = ?", whereArgs: [id]);
      return ResultData(res, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }

  static Future<ResultData> putNote(id, Map<String, Object?> data) async {
    data["updatedAt"] = new DateTime.now().toIso8601String();
    try {
      Database db = await databaseHelper.database;
       await db.update(DatabaseHelper.notesTableName, data,
          where: "id = ?", whereArgs: [id]);
      return ResultData(data, 200);
    } catch (e) {}
    return ResultData("err", 111);
  }
}
