import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/setting.dart';
import 'package:gtuner/main.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

const Map<String, double> guitar = {
  "E2": 82.4068892282175,
  "A": 110.0,
  "D": 146.8323839587038,
  "G": 195.99771799087463,
  "B": 246.94165062806206,
  "E4": 329.6275569128699,
};

const Map<String, double> ukulele = {
  "G": 391.99543598174927,
  "C": 261.6255653005986,
  "E": 329.6275569128699,
  "A": 440.00,
};

const Map<String, double> bass = {
  "E": 48.999429497718666,
  "A": 55.0,
  "D": 73.41619197935188,
  "G": 97.99885899543733,
};

double calibration = 440.0;

bool showPitch = false;

bool darkMode = true;

Map<String, double> tuninig = guitar;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.refresh}) : super(key: key);
  VoidCallback refresh;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double frequency = 0.0;
  String note = "F";
  double perfect = 0.0;
  double position = 0.0;
  var rng = Random();
  final _audioRecorder = FlutterAudioCapture();
  final pitchDetectorDart = PitchDetector(44100, 2000);
  late PitchHandler pitchupDart;
  String status = '';

  @override
  void initState() {
    super.initState();
    getData();
    pitchupDart = PitchHandler(
      InstrumentType.guitar,
      calibration,
    );
    checkPermission();
  }

  Future<void> _startCapture() async {
    await _audioRecorder.start(listener, onError,
        sampleRate: 44100, bufferSize: 3000);
  }

  Future<void> _stopCapture() async {
    await _audioRecorder.stop();
  }

  void listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();
    final result = pitchDetectorDart.getPitch(audioSample);

    if (result.pitched) {
      final handledPitchResult = pitchupDart.handlePitch(result.pitch);
      if (handledPitchResult.note != '') {
        setState(() {
          note = handledPitchResult.note;
          position = handledPitchResult.diffFrequency;
          perfect = handledPitchResult.expectedFrequency;
          status = handledPitchResult.tuningStatus.name.toString();
          frequency = handledPitchResult.frequency;
        });
      }
    }
  }

  void onError(Object e) {}

  checkPermission() async {
    if (await Permission.microphone.isGranted) {
      _startCapture();
    } else {
      Permission.microphone.request().then((value) {
        if (value.isGranted) {
          _startCapture();
        }
      });
    }
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String instrumentType = prefs.getString('InstrumentType') ?? "Guitar";
    int calib = prefs.getInt("calibration") ?? 440;
    bool sp = prefs.getBool("setShowPitch") ?? false;
    bool dm = prefs.getBool("darkMode") ?? true;
    setState(() {
      if (instrumentType == "Guitar") {
        tuninig = guitar;
      } else if (instrumentType == "Bass") {
        tuninig = bass;
      } else if (instrumentType == "Ukulele") {
        tuninig = ukulele;
      }
      calibration = calib.toDouble();
      showPitch = sp;
      darkMode = dm;
      darkTheme = dm;
      widget.refresh();
    });
  }

  @override
  void dispose() {
    _stopCapture();
    super.dispose();
  }

  refresh() {
    setState(() {
      pitchupDart = PitchHandler(
        InstrumentType.guitar,
        calibration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
              padding: const EdgeInsets.fromLTRB(20, 15, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "gTuner",
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(
                            refresh: refresh,
                            refreshMain: widget.refresh,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF222222),
                        Color(0xFF333333),
                      ],
                    ),
                  ),
                  width: screenSize.width / 1.4,
                  height: screenSize.width / 1.4,
                ),
                Positioned(
                  left: screenSize.width / 12,
                  top: screenSize.width / 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF222222),
                          Color(0xFF851BFF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    width: screenSize.width / 1.8,
                    height: screenSize.width / 1.8,
                  ),
                ),
                Positioned(
                  left: screenSize.width / 6.1,
                  top: screenSize.width / 6.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF2C2C2C),
                          Color(0xFF3A3A3A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 4,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    width: screenSize.width / 2.5,
                    height: screenSize.width / 2.5,
                    child: Center(
                      child: Text(
                        note.characters.first,
                        style:
                            const TextStyle(fontSize: 45, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            screenSize.height > 600
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i in tuninig.keys)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: (note.characters.first ==
                                          i.characters.first &&
                                      perfect == tuninig[i])
                                  ? darkMode
                                      ? [
                                          const Color(0xFF851BFF),
                                          const Color(0xFF851BFF),
                                        ]
                                      : [
                                          const Color.fromARGB(
                                              255, 178, 111, 255),
                                          const Color.fromARGB(
                                              255, 165, 86, 255),
                                        ]
                                  : darkMode
                                      ? [
                                          const Color(0xFF2C2C2C),
                                          const Color(0xFF3A3A3A),
                                        ]
                                      : [
                                          const Color(0xFFFCFCFC),
                                          const Color(0xFFEEEEEE),
                                        ],
                            ),
                          ),
                          width: screenSize.width / 7,
                          height: screenSize.width / 7,
                          child: Center(
                            child: Text(
                              i.characters.first,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                  )
                : Container(),
            const Spacer(),
            showPitch ? Text(perfect.toString()) : Container(),
            showPitch ? const Spacer() : Container(),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0;
                          i <= MediaQuery.of(context).size.width / 8;
                          i++)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2,
                            height: 50 + rng.nextInt(93 - 50).toDouble(),
                          ),
                        ),
                    ],
                  ),
                  Center(
                    child: Container(
                      color: Colors.green.withOpacity(0.6),
                      width: 2,
                      height: 100,
                    ),
                  ),
                  AnimatedPositioned(
                    width: 2.5,
                    height: 100,
                    left:
                        (MediaQuery.of(context).size.width / 2) + position * 12,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      color: status == "waytoohigh" || status == "waytoolow"
                          ? Colors.red
                          : status == "toolow" || status == "toohigh"
                              ? Colors.yellow
                              : status == "tuned"
                                  ? Colors.green
                                  : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
