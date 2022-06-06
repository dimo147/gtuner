import 'package:flutter/material.dart';

// Tuner

const Map<String, double> guitar = {
  "E2": 82.40,
  "A": 110.0,
  "D": 146.83,
  "G": 195.99,
  "B": 246.94,
  "E4": 329.62,
};

const Map<String, double> ukulele = {
  "G": 391.99,
  "C": 261.62,
  "E": 329.62,
  "A": 440.00,
};

const Map<String, double> bass = {
  "E": 41.203,
  "A": 55.0,
  "D": 73.41,
  "G": 97.99,
};
// Settings

double calibration = 440.0;

bool showPitch = false;

bool darkMode = true;

Map<String, double> tuninig = guitar;

List<Color> darkBackground = const [
  Color(0xFF2C2C2C),
  Color(0xFF0B0B0B),
];
List<Color> lightBackground = const [
  Color(0xFFFFFFFF),
  Color(0xFFe8e8e8),
];

// Metronome

int notes = 4;
int noteType = 4;
