import 'package:flutter/material.dart';
import 'package:one/utils/local_storage.dart';

class ThemeColorProvider with ChangeNotifier {
  int? themeColor ;

  ThemeColorProvider() {
    getThemeColor();
  }

  void getThemeColor() async {
    themeColor = await LocalStorage.getThemeColor();
    notifyListeners();
  }

  void setThemeColor(int color) async {
    themeColor = color;
    notifyListeners();
    await LocalStorage.setThemeColor(color);
  }
}
