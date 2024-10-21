import 'package:flutter/material.dart';
import 'package:one/pages/about.dart';
import 'package:one/pages/accounts/accounts.dart';
import 'package:one/pages/accounts/accounts_cards.dart';
import 'package:one/pages/authorize.dart';
import 'package:one/pages/audio/audio.dart';
import 'package:one/pages/baby/baby.dart';
import 'package:one/pages/health/health.dart';
import 'package:one/pages/home.dart';
import 'package:one/pages/notes/notes.dart';
import 'package:one/pages/setting/settting.dart';
import 'package:one/pages/tools/tools.dart';

class NavigatorUtil {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///home页面
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, Home.sName);
  }

  ///audio页面
  static goAudio(BuildContext context) {
    Navigator.pushReplacementNamed(context, Audio.sName);
  }

  ///账单页面
  static goAccounts(BuildContext context) {
    Navigator.pushReplacementNamed(context, Accounts.sName);
  }

  ///账单页面
  static goAccountsCard(BuildContext context) {
    Navigator.pushReplacementNamed(context, AccountsCards.sName);
  }

  ///便签页
  static goNotes(BuildContext context) {
    Navigator.pushReplacementNamed(context, Notes.sName);
  }

  ///健康页
  static goHealth(BuildContext context) {
    Navigator.pushReplacementNamed(context, Health.sName);
  }

  ///baby页
  static goBaby(BuildContext context) {
    Navigator.pushReplacementNamed(context, Baby.sName);
  }

  ///工具页
  static goTools(BuildContext context) {
    Navigator.pushReplacementNamed(context, Tools.sName);
  }

  ///设置页
  static goSetting(BuildContext context) {
    Navigator.pushReplacementNamed(context, Setting.sName);
  }

  ///指纹或面部认证页
  static goAuthorize(BuildContext context) {
    Navigator.pushReplacementNamed(context, Authorize.sName);
  }

  ///关于页
  static goAbout(BuildContext context) {
    Navigator.pushReplacementNamed(context, About.sName);
  }
}
