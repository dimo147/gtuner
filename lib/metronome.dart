import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import './consts.dart';
import 'dart:async';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({Key? key}) : super(key: key);

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  Timer? timer;
  int tempo = 75;
  int current = 1;
  bool isPlaying = false;
  final player = AudioPlayer();

  start() {
    timer = Timer.periodic(
        Duration(milliseconds: ((60 / tempo).toDouble() * 1000).toInt()),
        (Timer t) => playSound());
    isPlaying = true;
  }

  playSound() async {
    await player.setAsset('images/metronome_sound.wav');
    await player.setVolume(100);
    player.play();
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
              padding: const EdgeInsets.fromLTRB(6, 15, 12, 35),
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
                      "Metronome",
                      style: GoogleFonts.inter(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Center(
              child: Text(
                '$notes / $noteType',
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
                      boxShadow: darkMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                spreadRadius: 3,
                                blurRadius: 17,
                                offset: const Offset(2, 5),
                              ),
                            ]
                          : [
                              const BoxShadow(
                                color: Color(0xffADADAD),
                                spreadRadius: 4,
                                blurRadius: 12,
                                offset: Offset(3, 5),
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
            Text(
              tempo.toString(),
              style: const TextStyle(fontSize: 55),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black45,
                      Colors.black54,
                    ], stops: [
                      0,
                      1
                    ]),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      stop();
                      setState(() {
                        if (tempo > 35) {
                          tempo -= 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove),
                    iconSize: 55,
                    color: darkMode
                        ? Colors.white.withOpacity(0.88)
                        : Colors.black.withOpacity(0.78),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        stop();
                      } else {
                        start();
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 52,
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black54,
                      Colors.black45,
                    ], stops: [
                      0,
                      1
                    ]),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      stop();
                      setState(() {
                        if (tempo < 180) {
                          tempo += 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 55,
                    color: darkMode
                        ? Colors.white.withOpacity(0.88)
                        : Colors.black.withOpacity(0.78),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class RythmPicker extends StatefulWidget {
  const RythmPicker({Key? key}) : super(key: key);

  @override
  State<RythmPicker> createState() => _RythmPickerState();
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
