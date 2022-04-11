import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/home.dart';

void main() {
  runApp(const MyApp());
}

bool darkTheme = true;

ThemeData _darkTheme = ThemeData(
  accentColor: Colors.purpleAccent,
  brightness: Brightness.dark,
  primaryColor: Colors.purpleAccent,
);

ThemeData _lightTheme = ThemeData(
  accentColor: Colors.purpleAccent,
  brightness: Brightness.light,
  primaryColor: Colors.purpleAccent,
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  refreshMain() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Espanish
        Locale('fa', ''), // Persian
        Locale('fr', ''), // French
        Locale('ar', ''), // Arabic
        Locale('hi', ''), // Hindi
        Locale('he', ''), // Hebrew
        Locale('it', ''), // Italian
        Locale('ja', ''), // Japanese
        Locale('ko', ''), // Korean
        Locale('tr', ''), // Turkish
        Locale('ru', ''), // Russian
      ],
      debugShowCheckedModeBanner: false,
      title: 'gTuner',
      theme: darkTheme ? _darkTheme : _lightTheme,
      home: HomeScreen(
        refresh: refreshMain,
      ),
    );
  }
}
