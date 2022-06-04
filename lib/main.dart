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
  useMaterial3: true,
);

ThemeData _lightTheme = ThemeData(
  accentColor: Colors.purpleAccent,
  brightness: Brightness.light,
  primaryColor: Colors.purpleAccent,
  useMaterial3: true,
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
