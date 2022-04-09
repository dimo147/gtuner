import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/setting.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

double calibration = 440.0;

Map<String, double> tuninig = {
  "E2": 82.4068892282175,
  "A": 110.0,
  "D": 146.8323839587038,
  "G": 195.99771799087463,
  "B": 246.94165062806206,
  "E4": 329.6275569128699,
};

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
  "E": 41.204,
  "A": 55,
  "D": 73.416,
  "G": 97.999,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
  final pitchupDart = PitchHandler(InstrumentType.guitar);
  String status = '';

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
          print(perfect);
          status = handledPitchResult.tuningStatus.name.toString();
          frequency = handledPitchResult.frequency;
        });
      }
    }
  }

  void onError(Object e) {}

  @override
  void initState() {
    super.initState();
    getInstrumentType();
    checkPermission();
  }

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

  getInstrumentType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String instrumentType = prefs.getString('InstrumentType') ?? "Guitar";
    if (instrumentType == "Guitar") {
      tuninig = guitar;
    } else if (instrumentType == "Bass") {
      tuninig = bass;
    } else if (instrumentType == "Ukulele") {
      tuninig = ukulele;
    }
  }

  @override
  void dispose() {
    _stopCapture();
    super.dispose();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
              padding: const EdgeInsets.fromLTRB(18, 5, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tuner',
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(refresh: refresh),
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
                  width: screenSize.width / 1.2,
                  height: screenSize.width / 1.2,
                ),
                Positioned(
                  left: screenSize.width / 9.5,
                  top: screenSize.width / 9.5,
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
                    width: screenSize.width / 1.6,
                    height: screenSize.width / 1.6,
                  ),
                ),
                Positioned(
                  left: screenSize.width / 5,
                  top: screenSize.width / 5,
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
                    width: screenSize.width / 2.3,
                    height: screenSize.width / 2.3,
                    child: Center(
                      child: Text(
                        note.characters.first,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i in tuninig.keys)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: (note.characters.first == i.characters.first &&
                                perfect == tuninig[i])
                            ? [
                                const Color(0xFF851BFF),
                                const Color(0xFF851BFF),
                              ]
                            : [
                                const Color(0xFF2C2C2C),
                                const Color(0xFF3A3A3A),
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
            ),
            const Spacer(),
            Text(perfect.toString()),
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
