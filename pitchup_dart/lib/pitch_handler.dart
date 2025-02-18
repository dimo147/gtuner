library pitchupdart;

import 'dart:math';

import 'package:pitchupdart/pitch_result.dart';
import 'package:pitchupdart/tuning_status.dart';

class PitchHandler {
  final double tuningPitch;
  dynamic _minimumPitch;
  dynamic _maximumPitch;
  dynamic _noteStrings;

  PitchHandler(this.tuningPitch) {
    _minimumPitch = 20.0;
    _maximumPitch = 1050.0;
    _noteStrings = [
      "C",
      "C#",
      "D",
      "D#",
      "E",
      "F",
      "F#",
      "G",
      "G#",
      "A",
      "A#",
      "B"
    ];
  }

  PitchResult handlePitch(double pitch) {
    if (_isPitchInRange(pitch)) {
      final noteLiteral = _noteFromPitch(pitch);
      final expectedFrequency = _frequencyFromNoteNumber(_midiFromPitch(pitch));
      final diff = _diffFromTargetedNote(pitch);
      final tuningStatus = _getTuningStatus(diff);

      return PitchResult(
          noteLiteral, tuningStatus, expectedFrequency, diff, pitch);
    }

    return PitchResult("", TuningStatus.undefined, 0.00, 0.00, 0.00);
  }

  bool _isPitchInRange(double pitch) {
    return pitch > _minimumPitch && pitch < _maximumPitch;
  }

  String _noteFromPitch(double frequency) {
    final noteNum = 12.0 * (log((frequency / tuningPitch)) / log(2.0));
    return _noteStrings[
        ((noteNum.roundToDouble() + 69.0).toInt() % 12.0).toInt()];
  }

  double _diffFromTargetedNote(double pitch) {
    final targetPitch = _frequencyFromNoteNumber(_midiFromPitch(pitch));
    return targetPitch - pitch;
  }

  TuningStatus _getTuningStatus(double diff) {
    if (diff >= -4 && diff <= 4) {
      return TuningStatus.tuned;
    } else if (diff >= -8 && diff <= 4) {
      return TuningStatus.toohigh;
    } else if (diff > 4 && diff <= 8) {
      return TuningStatus.toolow;
    } else if (diff >= double.negativeInfinity && diff <= -8) {
      return TuningStatus.waytoohigh;
    } else {
      return TuningStatus.waytoolow;
    }
  }

  int _midiFromPitch(double frequency) {
    final noteNum = 12.0 * (log((frequency / tuningPitch)) / log(2.0));
    return (noteNum.roundToDouble() + 69.0).toInt();
  }

  double _frequencyFromNoteNumber(int note) {
    final exp = (note - 69.0).toDouble() / 12.0;
    return (tuningPitch * pow(2.0, exp)).toDouble();
  }
}
