import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:one/config/global.dart';
import 'package:one/model/book_model.dart';

class LocalStorage {
  static const String heightKey = "heightKey";
  static const String mmKey = "mmKey";
  static const String playSkipSecondsKey = "playSkipSecondsKey";
  static const String booksKey = "booksKey";
  static const String currentBookKey = "currentBookKey";
  static const String localBookDirectoryKey = "localBookDirectoryKey";
  static const String defaultPageKey = "defaultPageKey";
  static const String headImgKey = "headImgKey";
  static const String headTextKey = "headTextKey";
  static const String themeColorKey = "themeColorKey";
  static const String casfafKey = "casfafKey";

  static Future<void> setBool(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool> getBool(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setVal(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value.toString());
  }

  static Future<String?> getVal(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setHeightVal(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(heightKey, value.toString());
  }

  static Future<String?> getHeightVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(heightKey);
  }

  static Future<bool?> setMMVal(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(mmKey, value.toString());
  }

  static Future<bool?> clearMMVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(mmKey);
  }

  static Future<String?> getMMVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(mmKey);
  }

  static Future<bool?> setBooksVal(List list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(booksKey, jsonEncode(list));
  }

  static Future<List<BookModel>> getBooksVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(booksKey);
    if (val != null) {
      try {
        List list = jsonDecode(val);
        return list.map((e) => BookModel.fromJson(e)).toList();
      } catch (e) {
        print(e);
      }
    }
    return [];
  }

  static Future<bool?> setCurrentBookVal(BookModel? book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (book == null) {
      return prefs.remove(currentBookKey);
    }
    return prefs.setString(currentBookKey, jsonEncode(book.toJson()));
  }

  static Future<BookModel?> getCurrentBookVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(currentBookKey);
    if (val != null) {
      try {
        var data = jsonDecode(val);
        return BookModel.fromJson(data);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  static Future<bool> setPlaySkipSeconds(List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(playSkipSecondsKey, jsonEncode((list)));
  }

  static Future<List<Duration>> getPlaySkipSeconds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(playSkipSecondsKey);
    if (val != null) {
      try {
        List list = jsonDecode(val);
        return list.map((e) => Duration(seconds: int.parse(e))).toList();
      } catch (e) {
        print(e);
      }
    }
    return [Duration.zero, Duration.zero];
  }

  static Future<bool> setLocalBookDirectory(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(localBookDirectoryKey, val);
  }

  static Future<String> getLocalBookDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(localBookDirectoryKey) ?? Global.bookLocalPath;
  }

  static Future<bool> setDefaultPage(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(defaultPageKey, val);
  }

  static Future<String> getDefaultPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(defaultPageKey) ?? Global.pages[0].route;
  }

  static Future<bool> setHeadImg(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(headImgKey, val);
  }

  static Future<String?> getHeadImg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(headImgKey);
  }

  static Future<bool> setHeadText(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(headTextKey, val);
  }

  static Future<String> getHeadText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(headTextKey) ?? Global.headText;
  }

  static Future<bool> setCasfaf(List<String> val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(casfafKey, val);
  }

  static Future<List<String>?> getCasfaf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(casfafKey) ;
  }

  static Future<bool> setThemeColor(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(themeColorKey, val);
  }

  static Future<int> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(themeColorKey) ?? Global.themeColor.value;
  }
}
