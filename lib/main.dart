import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:one/config/global.dart';
import 'package:one/provider/theme_color_provider.dart';
import 'package:one/utils/database_helper.dart';
import 'package:one/utils/local_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:one/pages/about.dart';
import 'package:one/pages/accounts/accounts.dart';
import 'package:one/pages/authorize.dart';
import 'package:one/pages/audio/audio.dart';
import 'package:one/pages/baby/baby.dart';
import 'package:one/pages/health/health.dart';
import 'package:one/pages/home.dart';
import 'package:one/pages/notes/notes.dart';
import 'package:one/pages/setting/settting.dart';
import 'package:one/pages/tools/tools.dart';
import 'package:one/provider/audio_provider.dart';
import 'package:one/provider/authorize_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Provider.debugCheckInvalidValueType = null;
  final provides = [
    ChangeNotifierProvider(create: (_) => ThemeColorProvider()),
    ChangeNotifierProvider(create: (_) => AudioProvider()),
    ChangeNotifierProvider(create: (_) => AuthorizeProvide()),
  ];
  String defaultPage = await LocalStorage.getDefaultPage();
  runApp(MultiProvider(
      providers: provides,
      child: MyApp(
        defaultPage: defaultPage,
      )));
}

class MyApp extends StatefulWidget {
  final String defaultPage;
  const MyApp({super.key, required this.defaultPage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    databaseHelper.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int? themeColor = context.watch<ThemeColorProvider>().themeColor;
    if (themeColor == null) return const MaterialApp();
    return OverlaySupport.global(
      child: MaterialApp(
        title: Global.appName,
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          cardTheme: const CardTheme(
              color: Color.fromARGB(221, 28, 28, 28),
              elevation: 0,
              margin: EdgeInsets.zero),
          colorScheme: ColorScheme.dark(
            surface: Color.fromARGB(248, 17, 17, 17),
            primary: Color(themeColor),
            onPrimary: Colors.white,
            secondary: Color(themeColor),
          ),
        ),
        theme: ThemeData(
          cardTheme: const CardTheme(
              color: Colors.white, elevation: 0, margin: EdgeInsets.zero),
          tabBarTheme: const TabBarTheme(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white54,
          ),
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Color(themeColor),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(themeColor),
            primary: Color(themeColor),
            secondary: Colors.black87,
          ),
          secondaryHeaderColor: Color(themeColor).withAlpha(35),
          useMaterial3: true,
        ),
        initialRoute: widget.defaultPage,
        routes: {
          Home.sName: (BuildContext context) => const Home(),
          Authorize.sName: (BuildContext context) => const Authorize(),
          About.sName: (BuildContext context) => const About(),
          Accounts.sName: (BuildContext context) => const Accounts(),
          Notes.sName: (BuildContext context) => const Notes(),
          Health.sName: (BuildContext context) => const Health(),
          Baby.sName: (BuildContext context) => const Baby(),
          Tools.sName: (BuildContext context) => const Tools(),
          Setting.sName: (BuildContext context) => const Setting(),
          Audio.sName: (BuildContext context) => const Audio(),
        },
        home: const Home(),
      ),
    );
  }
}
