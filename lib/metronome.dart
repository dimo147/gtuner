import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gtuner/setting.dart';
import 'package:gtuner/home.dart';
import 'dart:async';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({Key? key}) : super(key: key);

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int tempo = 75;
  int notes = 4;
  int noteType = 4;
  int current = 1;
  Timer? timer;
  bool isPlaying = false;
  static AudioCache player = AudioCache(
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
    String audioasset = "metronome.wav";
    await player.play(audioasset, mode: PlayerMode.LOW_LATENCY);
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
              padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 32,
                    ),
                  ),
                  const Text(
                    "Metronome",
                    style: TextStyle(fontSize: 21),
                  ),
                  Container(width: 50),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                notes.toString() + ' / ' + noteType.toString(),
                style: const TextStyle(fontSize: 30),
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
                      color: (current == i)
                          ? Colors.deepPurple
                          : Colors.grey.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    width: (current == i) ? 20 : 15,
                    height: (current == i) ? 20 : 15,
                  ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white, thickness: 1),
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
                    iconSize: 40,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  Text(
                    tempo.toString(),
                    style: const TextStyle(fontSize: 60),
                  ),
                  IconButton(
                    onPressed: () {
                      stop();
                      setState(() {
                        if (tempo < 130) {
                          tempo += 1;
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 40,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  setState(() {
                    if (tempo < 130) {
                      tempo += 1;
                    }
                  });
                } else if (details.delta.dx < 0) {
                  setState(() {
                    if (tempo > 35) {
                      tempo -= 1;
                    }
                  });
                }
              },
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(colors: [
                    Color.fromARGB(255, 223, 223, 223),
                    Colors.grey,
                  ]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      spreadRadius: 5,
                      blurRadius: 40,
                      offset: const Offset(-5, 5),
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
                IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      stop();
                    } else {
                      start();
                    }
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 35),
                )
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
