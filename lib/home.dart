import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import './metronome.dart';
import './ad_helper.dart';
import 'dart:typed_data';
import './setting.dart';
import './consts.dart';
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.refresh}) : super(key: key);
  final VoidCallback refresh;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pitchDetectorDart = PitchDetector(44100, 2000);
  final _audioRecorder = FlutterAudioCapture();
  late PitchHandler pitchupDart;
  double frequency = 0.0;
  double position = 0.0;
  double perfect = 0.0;
  var rng = Random();
  String status = '';
  String note = "F";

  bool _isInterstitialAdReady = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    getData();
    pitchupDart = PitchHandler(
      calibration,
    );
    checkPermission();
    _initGoogleMobileAds();
    _loadInterstitialAd();
    Future.delayed(const Duration(seconds: 50), () {
      if (_isInterstitialAdReady) {
        _interstitialAd?.show();
      }
    });
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
              Future.delayed(const Duration(seconds: 150), () {
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: ShowUpAnimation(
                delayStart: const Duration(milliseconds: 300),
                animationDuration: const Duration(seconds: 1),
                direction: Direction.vertical,
                curve: Curves.fastOutSlowIn,
                offset: 0.5,
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
                        width: 35,
                        height: 35,
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
            ),
            const Spacer(),
            ShowUpAnimation(
              delayStart: const Duration(milliseconds: 500),
              animationDuration: const Duration(seconds: 1),
              direction: Direction.vertical,
              curve: Curves.fastOutSlowIn,
              offset: 0.5,
              child: Container(
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
            ),
            const Spacer(),
            if (showPitch)
              ShowUpAnimation(
                delayStart: const Duration(milliseconds: 700),
                animationDuration: const Duration(seconds: 1),
                direction: Direction.vertical,
                curve: Curves.fastOutSlowIn,
                offset: 0.5,
                child: Text(
                  frequency.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            if (showPitch) const Spacer(),
            ShowUpAnimation(
              delayStart: const Duration(milliseconds: 700),
              animationDuration: const Duration(seconds: 1),
              direction: Direction.vertical,
              curve: Curves.fastOutSlowIn,
              offset: 0.5,
              child: SizedBox(
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
                      left: (MediaQuery.of(context).size.width / 2) +
                          position * 9,
                      duration: const Duration(milliseconds: 900),
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
            ),
            const Spacer(),
            if (screenSize.height > 600)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i in tuninig.keys)
                    ShowUpAnimation(
                      delayStart: const Duration(milliseconds: 900),
                      animationDuration: const Duration(seconds: 1),
                      direction: Direction.vertical,
                      curve: Curves.fastOutSlowIn,
                      offset: 0.5,
                      child: Container(
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
                                      inRange(
                                          perfect.toInt(), tuninig[i]?.toInt()))
                                  ? const Color(0xfff3f3f3)
                                  : darkMode
                                      ? const Color(0xfff3f3f3)
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 25),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
