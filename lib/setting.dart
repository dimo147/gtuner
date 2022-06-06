import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/ad_helper.dart';
import 'package:gtuner/consts.dart';
import 'package:gtuner/main.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({Key? key, required this.refresh, required this.refreshMain})
      : super(key: key);
  VoidCallback refresh;
  VoidCallback refreshMain;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int value = 1;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tuning Calibration'),
          content: const IntegerPicker(),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    darkMode ? Colors.white : Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setCalib();
              },
            ),
          ],
        );
      },
    );
  }

  setCalib() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calibration', calibration.toInt());
    widget.refresh();
    setState(() {});
  }

  setShowPitch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showPitch', showPitch);
  }

  setDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    setState(() {
      widget.refreshMain();
    });
  }

  getInstrumentType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = prefs.getString('InstrumentType') ?? "Guitar";

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
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: darkMode ? darkBackground : lightBackground,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 15, 12, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 35,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Settings",
                      style: GoogleFonts.inter(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 45),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
              child: Row(
                children: const [
                  Text(
                    "Instrument",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CustomRadioButton("Guitar", 1, 'images/spanish-guitar.png'),
                CustomRadioButton("Ukulele", 2, "images/ukelele.png"),
                CustomRadioButton("Bass", 3, "images/bass.png")
              ],
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                children: const [
                  Text(
                    "Tuner",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Calibration"),
              onTap: () {
                _showMyDialog();
              },
              trailing: Opacity(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(calibration.toInt().toString() + " Hz"),
                ),
                opacity: 0.6,
              ),
            ),
            SwitchListTile(
              value: showPitch,
              title: const Text("Frequency"),
              onChanged: (value) {
                setState(() {
                  showPitch = value;
                  setShowPitch();
                  widget.refresh();
                });
              },
            ),
            SwitchListTile(
              value: darkMode,
              title: const Text("Dark Mode"),
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                  setDarkMode();
                  widget.refresh();
                });
              },
            ),
            // ListTile(
            //   title: const Text("Rate us"),
            //   onTap: () {},
            // ),
            // ListTile(
            //   title: const Text("Terms of Service"),
            //   onTap: () {},
            // ),
            const Spacer(),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget CustomRadioButton(String text, int index, String image) {
    double screenWidth = MediaQuery.of(context).size.width;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          value = index;
        });
        setInstrumentType(text);
        widget.refresh();
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
            color: (value == index)
                ? const Color(0xFF9B44FF)
                : darkMode
                    ? Colors.white30
                    : Colors.black26),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              image,
              width: screenWidth < 572 ? screenWidth / 3 - 75 : 572 / 3 - 75,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              text,
              style: TextStyle(
                color: (value == index)
                    ? const Color(0xFF9B44FF)
                    : darkMode
                        ? Colors.white70
                        : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntegerPicker extends StatefulWidget {
  const IntegerPicker({Key? key}) : super(key: key);

  @override
  _IntegerPickerState createState() => _IntegerPickerState();
}

class _IntegerPickerState extends State<IntegerPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NumberPicker(
          value: calibration.toInt(),
          textStyle: TextStyle(color: darkMode ? Colors.white : Colors.black),
          minValue: 280,
          maxValue: 600,
          onChanged: (value) => setState(() => calibration = value.toDouble()),
        ),
      ],
    );
  }
}
