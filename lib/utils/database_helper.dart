import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:one/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

class DatabaseHelper {
  static Database? _database;
  static String costTypeTableName = "cost_type";
  static String accountTableName = "account";
  static String personTableName = "person";
  static String healthTableName = "health";
  static String babyoptionTableName = "babyoption";
  static String babyTableName = "baby";
  static String notesTableName = "notes";

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDataBase();
    return _database!;
  }

  Future _getDbPath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, Global.databaseName);

    return path;
  }

  Future<Database?> initDataBase() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      String path = await _getDbPath();
      // Open the database and store its reference.
      Database db = await openDatabase(path,
          version: 1,
          onCreate: _onCreate,
          password: "doadjfaksdf435432534n4lm");
      return db;
    } catch (e) {
      showErrorMsg(e.toString());
    }
    return null;
  }

  Future _onCreate(Database db, int version) async {
    // Run the CREATE TABLE statement on the database.
    await db.execute(
      'CREATE TABLE $costTypeTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, isIncome INTEGER)',
    );
    await db.execute(
      'CREATE TABLE $accountTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, isIncome INTEGER, costType TEXT, money INTEGER, time TEXT, remark TEXT)',
    );
    await db.execute(
      'CREATE TABLE $personTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, updatedAt TEXT)',
    );
    await db.execute(
      'CREATE TABLE $healthTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, weight REAL, height REAL, bmi REAL, time TEXT, person TEXT)',
    );
    await db.execute(
      'CREATE TABLE $babyoptionTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, updatedAt TEXT)',
    );
    await db.execute(
      'CREATE TABLE $babyTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, option TEXT, startTime TEXT, endTime TEXT)',
    );
    await db.execute(
      'CREATE TABLE $notesTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, updatedAt TEXT)',
    );
    // insert default data
    insertDefaultData(db);
  }

  Future insertDefaultData(db) async {
    for (var e in Global.costTypeDb) {
      await db.insert("cost_type", e);
    }
    for (var e in Global.personDb) {
      await db.insert("person", e);
    }
    for (var e in Global.babyoptionDb) {
      await db.insert("babyoption", e);
    }
  }

  // Close the database
  Future closeDatabase() async {
    if (_database != null) {
      // Closing the database
      await _database!.close();
      _database = null;
    }
  }

  // backup database
  Future<void> backupDatabase(String backupPath) async {
    String dbPath = await _getDbPath();
    String fileName = Global.databaseName.replaceAll(
        ".db", DateFormat("yyyyMMddHHmmss").format(DateTime.now()) + ".db");
    backupPath = join(backupPath, fileName);

    Uint8List backupData = await File(dbPath).readAsBytes();
    await File(backupPath).writeAsBytes(backupData);
  }

// restore database
  Future<void> restoreDatabase(Uint8List fileData) async {
    await closeDatabase();
    String dbPath = await _getDbPath();
    await File(dbPath).writeAsBytes(fileData);
    await initDataBase();
  }
}
