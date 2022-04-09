import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/home.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({Key? key, required this.refresh}) : super(key: key);
  VoidCallback refresh;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int value = 1;

  getInstrumentType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? type = prefs.getString('InstrumentType');
    setState(() {
      if (type == "Guitar") {
        value = 1;
      } else if (type == "Bass") {
        value = 3;
      } else if (type == "Ukulele") {
        value = 2;
      }
    });
  }

  setInstrumentType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('InstrumentType', type);
    if (type == "Guitar") {
      tuninig = guitar;
    } else if (type == "Bass") {
      tuninig = bass;
    } else if (type == "Ukulele") {
      tuninig = ukulele;
    }
  }

  @override
  void initState() {
    super.initState();
    getInstrumentType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2C2C2C),
              Color(0xFF080808),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.refresh();
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CustomRadioButton("Guitar", 1, 'images/spanish-guitar.png'),
                CustomRadioButton("Ukulele", 2, "images/ukelele.png"),
                CustomRadioButton("Bass", 3, "images/bass.png")
              ],
            ),
            const SizedBox(height: 20),
            // SizedBox(
            // child: ListTile(
            // title: const Text('Calibrate'),
            // onTap: () {},
            // ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget CustomRadioButton(String text, int index, String image) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          value = index;
        });
        setInstrumentType(text);
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
            color: (value == index) ? const Color(0xFF9B44FF) : Colors.white30),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              image,
              width: MediaQuery.of(context).size.width / 3 - 60,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              text,
              style: TextStyle(
                color:
                    (value == index) ? const Color(0xFF9B44FF) : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
