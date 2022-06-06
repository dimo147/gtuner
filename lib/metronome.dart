import 'package:audioplayers/audioplayers.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/consts.dart';
import 'dart:async';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({Key? key}) : super(key: key);

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int tempo = 75;
  int current = 1;
  Timer? timer;
  bool isPlaying = false;
  static AudioCache player = AudioCache(
    prefix: "images/",
    fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
  );
  static AudioCache player2 = AudioCache(
    prefix: "images/",
    fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
  );
  static AudioCache player3 = AudioCache(
    prefix: "images/",
    fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
  );

  @override
  void initState() {
    super.initState();
  }

  start() {
    timer = Timer.periodic(
        Duration(milliseconds: ((60 / tempo).toDouble() * 1000).toInt()),
        (Timer t) => playSound());
    isPlaying = true;
  }

  playSound() async {
    if (notes % 2 == 1 && current == 1) {
      await player3.play("metronome.flac", mode: PlayerMode.LOW_LATENCY);
    } else if (current % 2 == 0) {
      await player.play("metronome.flac", mode: PlayerMode.LOW_LATENCY);
    } else {
      await player2.play("metronome.flac", mode: PlayerMode.LOW_LATENCY);
    }
    setState(() {
      if (current == notes) {
        current = 1;
      } else {
        current += 1;
      }
    });
  }

  stop() {
    timer?.cancel();
    setState(() {
      current = 1;
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
              padding: const EdgeInsets.fromLTRB(3, 15, 12, 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 38,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      "Metronome",
                      style: GoogleFonts.inter(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 55),
                ],
              ),
            ),
            Center(
              child: Text(
                notes.toString() + ' / ' + noteType.toString(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 1; i <= notes; i++)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: (current == i)
                            ? const [
                                Color(0xffBB49E3),
                                Color(0xff5E007E),
                              ]
                            : const [
                                Color(0xff6F6F6F),
                                Color(0xff3C3C3C),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          spreadRadius: 3,
                          blurRadius: 17,
                          offset: const Offset(2, 5),
                        ),
                      ],
                    ),
                    width: (current == i) ? 32 : 27,
                    height: (current == i) ? 32 : 27,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Spacer(),
            FractionallySizedBox(
              widthFactor: 0.82,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      stop();
                      setState(() {
                        if (tempo > 35) {
                          tempo -= 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove),
                    iconSize: 60,
                    color: Colors.white.withOpacity(0.88),
                  ),
                  Text(
                    tempo.toString(),
                    style: const TextStyle(fontSize: 55),
                  ),
                  IconButton(
                    onPressed: () {
                      stop();
                      setState(() {
                        if (tempo < 180) {
                          tempo += 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 60,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) {
                  setState(() {
                    if (tempo < 180) {
                      tempo += 1;
                    }
                  });
                } else if (details.delta.dy > 0) {
                  setState(() {
                    if (tempo > 35) {
                      tempo -= 1;
                    }
                  });
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff000000),
                      Color(0x00D9D9D9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      spreadRadius: 8,
                      blurRadius: 25,
                      offset: const Offset(10, 12),
                    ),
                  ],
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 26, bottom: 10),
                  child: IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        stop();
                      } else {
                        start();
                      }
                    },
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 52),
                  ),
                )
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class RythmPicker extends StatefulWidget {
  const RythmPicker({Key? key}) : super(key: key);

  @override
  _RythmPickerState createState() => _RythmPickerState();
}

class _RythmPickerState extends State<RythmPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NumberPicker(
          value: notes,
          textStyle: const TextStyle(color: Colors.white, fontSize: 20),
          selectedTextStyle: const TextStyle(
              color: Color.fromARGB(255, 255, 92, 146), fontSize: 30),
          minValue: 2,
          maxValue: 12,
          onChanged: (value) => setState(() => notes = value),
        ),
      ],
    );
  }
}
