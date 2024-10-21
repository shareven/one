import 'package:flutter/material.dart';
import 'package:one/model/book_model.dart';
import 'package:one/model/page_model.dart';
import 'package:one/pages/about.dart';
import 'package:one/pages/accounts/accounts.dart';
import 'package:one/pages/audio/audio.dart';
import 'package:one/pages/baby/baby.dart';
import 'package:one/pages/health/health.dart';
import 'package:one/pages/home.dart';
import 'package:one/pages/notes/notes.dart';
import 'package:one/pages/setting/settting.dart';
import 'package:one/pages/tools/tools.dart';

class Global {
  static const themeColor = Colors.pink;
  static const databaseName = "one_database.db";
  static const String appName = "One";
  static const String headText = "小仙女&&&&爱你哟";
  static const String githubUrl = "https://github.com/shareven/one";
  static const String noDataFoundImg = "assets/images/nodatafound.png";
  static const String bookLocalPath = "/storage/emulated/0/Music/book";
  // 定时关闭听书，时间：分钟
  static const List<int> closeTimeList = [0, 10, 20, 30, 40, 60, 90];
  // 每3s自动保存播放进度 | Automatically save playback progress every 3 seconds
  static const int autoSaveSeconds = 3;
  static List<BookModel> books = [
    // BookModel.fromJson({
    //   "name": "凡人修仙传",
    //   "artUrl":audiobookdImg,
    //   "start": 1,
    //   "end": 2613,
    // }),
  ];
  static List<MaterialColor> themeColors = [
    Colors.pink,
    Colors.amber,
    Colors.blue,
    Colors.cyan,
    Colors.orange,
    Colors.green,
    Colors.lime,
    Colors.indigo,
    Colors.purple,
  ];
  static List<PageModel> pages = [
    PageModel("关于", About.sName),
    PageModel("首页", Home.sName),
    PageModel("听书", Audio.sName),
    PageModel("账单", Accounts.sName),
    PageModel("便签", Notes.sName),
    PageModel("宝贝", Baby.sName),
    PageModel("健康", Health.sName),
    PageModel("工具", Tools.sName),
    PageModel("设置", Setting.sName),
  ];

  static const babyoptionDb = [
    {"name": "母乳", "updatedAt": "2024-10-17T07:30:37.649Z"},
    {"name": "奶粉", "updatedAt": "2024-10-17T07:30:38.649Z"},
    {"name": "睡觉", "updatedAt": "2024-10-17T07:30:39.649Z"},
    {"name": "大便", "updatedAt": "2024-10-17T07:30:40.649Z"},
  ];

  static const costTypeDb = [
    {"name": "微信支出", "isIncome": 0},
    {"name": "花呗", "isIncome": 0},
    {"name": "借钱出去", "isIncome": 0},
    {"name": "车贷", "isIncome": 0},
    {"name": "支付宝支出", "isIncome": 0},
    {"name": "银行卡支出", "isIncome": 0},
    {"name": "其他支出", "isIncome": 0},
    {"name": "工资", "isIncome": 1},
    {"name": "还我钱", "isIncome": 1},
    {"name": "借钱进来", "isIncome": 1},
    {"name": "微信红包", "isIncome": 1},
    {"name": "接私活", "isIncome": 1},
    {"name": "其他收入", "isIncome": 1},
  ];

  static const personDb = [
    {"name": "我", "updatedAt": "2024-10-17T07:30:37.649Z"},
  ];
}
