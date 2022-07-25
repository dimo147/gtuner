import 'package:flutter/material.dart';
import './consts.dart';
import './home.dart';

void main() {
  Paint.enableDithering = true;
  runApp(const MyApp());
}

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
      theme: darkMode ? darkTheme : lightTheme,
      home: HomeScreen(
        refresh: refreshMain,
      ),
    );
  }
}
