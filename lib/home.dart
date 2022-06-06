import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtuner/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/metronome.dart';
import 'package:gtuner/setting.dart';
import 'package:gtuner/consts.dart';
import 'package:gtuner/main.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

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

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    getData();
    pitchupDart = PitchHandler(
      InstrumentType.guitar,
      calibration,
    );
    checkPermission();
    _initGoogleMobileAds();
    _loadInterstitialAd();
    // Future.delayed(const Duration(seconds: 50), () {
    //   if (_isInterstitialAdReady) {
    //     _interstitialAd?.show();
    //   }
    // });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _loadInterstitialAd();
              Future.delayed(const Duration(seconds: 110), () {
                if (_isInterstitialAdReady) {
                  _interstitialAd?.show();
                }
              });
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          _isInterstitialAdReady = false;
        },
      ),
    );
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

  inRange(perfect, tuning) {
    if (tuning < perfect + 5 && tuning > perfect - 5) {
      return true;
    } else {
      return false;
    }
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String instrumentType = prefs.getString('InstrumentType') ?? "Guitar";
    int calib = prefs.getInt("calibration") ?? 440;
    bool sp = prefs.getBool("showPitch") ?? false;
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
    _interstitialAd?.dispose();
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
              padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MetronomeScreen(),
                        ),
                      );
                    },
                    icon: Image.asset(
                      "images/metronome.png",
                      width: 100,
                      height: 100,
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "gTuner",
                    style: GoogleFonts.inter(
                        fontSize: 25, fontWeight: FontWeight.w500),
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: darkMode
                      ? const [
                          Color(0xFF404040),
                          Color(0xFF272727),
                        ]
                      : const [
                          Color(0xFFFDFDFD),
                          Color(0xFFC7C7C7),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: darkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 6,
                          blurRadius: 35,
                          offset: const Offset(12, 18),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0xffADADAD),
                          spreadRadius: 5,
                          blurRadius: 40,
                          offset: Offset(12, 15),
                        ),
                      ],
              ),
              width: screenSize.width * 0.55,
              height: screenSize.width * 0.55,
              child: Center(
                child: Text(
                  note,
                  style: GoogleFonts.lato(
                    fontSize: 65,
                  ),
                ),
              ),
            ),
            const Spacer(),
            showPitch
                ? Text(
                    frequency.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 18),
                  )
                : Container(),
            showPitch ? const Spacer() : Container(),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0;
                          i <= MediaQuery.of(context).size.width / 10;
                          i++)
                        Container(
                          color: darkMode
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.black.withOpacity(0.55),
                          width: 2,
                          height: 25 + rng.nextInt(93 - 25).toDouble(),
                        ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2 - 1),
                    color: Colors.green.withOpacity(0.6),
                    width: 2,
                    height: 100,
                  ),
                  AnimatedPositioned(
                    width: 2.5,
                    height: 100,
                    left:
                        (MediaQuery.of(context).size.width / 2) + position * 9,
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
            const Spacer(),
            screenSize.height > 600
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i in tuninig.keys)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: (note.characters.first ==
                                          i.characters.first &&
                                      inRange(
                                          perfect.toInt(), tuninig[i]?.toInt()))
                                  ? [
                                      const Color(0xFF851BFF),
                                      const Color(0xFF851BFF),
                                    ]
                                  : darkMode
                                      ? [
                                          const Color(0xFF3A3A3A),
                                          const Color(0xFF2C2C2C),
                                        ]
                                      : [
                                          const Color(0xFFEEEEEE),
                                          const Color(0xFFe0e0e0),
                                        ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: darkMode
                                ? const [
                                    BoxShadow(
                                      color: Color(0xFF000000),
                                      spreadRadius: 3,
                                      blurRadius: 15,
                                      offset: Offset(5, 5),
                                    ),
                                  ]
                                : const [
                                    BoxShadow(
                                      color: Color(0xffADADAD),
                                      spreadRadius: 1,
                                      blurRadius: 12,
                                      offset: Offset(2, 3),
                                    ),
                                  ],
                          ),
                          width: screenSize.width / 7,
                          height: screenSize.width / 7,
                          child: Center(
                            child: Text(
                              i.characters.first,
                              style: GoogleFonts.inter(
                                fontSize: 19,
                                color: (note.characters.first ==
                                            i.characters.first &&
                                        inRange(perfect.toInt(),
                                            tuninig[i]?.toInt()))
                                    ? const Color(0xfff3f3f3)
                                    : darkMode
                                        ? const Color(0xfff3f3f3)
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 25),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
