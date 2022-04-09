import 'package:flutter/material.dart';
import 'package:gtuner/home.dart';

void main() {
  runApp(const MyApp());
}

bool darkTheme = false;

ThemeData _darkTheme = ThemeData(
  accentColor: Colors.red,
  brightness: Brightness.dark,
  primaryColor: Colors.amber,
);

ThemeData _lightTheme = ThemeData(
  accentColor: Colors.pink,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
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
      debugShowCheckedModeBanner: false,
      title: 'gTuner',
      theme: darkTheme ? _darkTheme : _lightTheme,
      home: HomeScreen(
        refresh: refreshMain,
      ),
    );
  }
}
