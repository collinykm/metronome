import "package:flutter/material.dart";
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:metronome_app/service/play_sound_mixin.dart';
import 'package:metronome_app/service/subdivision.dart';

class MetronomeProvider with ChangeNotifier, PlaySound{

  int _tempo = 120;
  List<int> _accentsList = [3, 1, 2, 1];
  Subdivision _subdivision = allSubdivisionsMap[4]![0];

  List<int> _meter = [4, 4];
  bool _isPlaying = false;

  int get tempo => _tempo;
  List<int> get accentsList => _accentsList;
  Subdivision get subdivision => _subdivision;
  List<int> get subdivisionList => _subdivision.subdivisionList;
  List<int> get meter => _meter;
  bool get isPlaying => _isPlaying;
  double initialAngle() => (_tempo - 20)*8*pi/380;

  /*
  explanation on these fields: each element in accentsList represents the pitch of the click.
  subdivision list goes like this: subdivision[0] represents how many times is each beat getting divided into.
    ex. i want triplets, them subdivision[0] is 3. if i want sixteenths, then subdivision[0] is 4
  meter[0] represents how many beats are in each bar. meter[1] represents the value of each beat. so 4 is quarter note, 2 is half note, etc.
  */



  bool _isMeterPopupVisible = false;
  bool get isMeterPopupVisible => _isMeterPopupVisible;
  void toggleMeterVisibility() {
    _isMeterPopupVisible = !_isMeterPopupVisible;
    notifyListeners();
  }

  bool _isSubdivisionPopupVisible = false;
  bool get isSubdivisionPopupVisible => _isSubdivisionPopupVisible;
  void toggleSubdivisionVisibility() {
    _isSubdivisionPopupVisible = !_isSubdivisionPopupVisible;
    notifyListeners();
  }



  void Pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  void Play() async {
    if (isPlaying) {
      return;
    }
    _isPlaying = true;

    initializePlayer();

    int currentPulse = 0;
    while (isPlaying) {
      int beatTime = (60 / _tempo * pow(10, 6)).toInt();
      int pulseTime = beatTime ~/ subdivisionList[0];
      tickInTime(currentPulse);
      currentPulse++;
      currentPulse = currentPulse % (meter[0] * subdivisionList[0]);
      await Future.delayed(Duration(microseconds: pulseTime));
    }
  }

  void tickInTime(int currentPulse) {
    int currentBeat = currentPulse ~/ subdivisionList[0];
    int pulseInBeat = currentPulse % subdivisionList[0] + 1;
    int intensity;
    if (currentPulse % subdivisionList[0] == 0) {
      intensity = _accentsList[currentBeat] * subdivisionList[pulseInBeat];
    } else {
      intensity = subdivisionList[pulseInBeat];
    }

    playSound(intensity: intensity);
    currentPulse++;
    currentPulse = currentPulse % (meter[0] * subdivisionList[0]);
  }






  void updateTempo(int tempo) {
    _tempo = tempo;
    notifyListeners();
  }

  void updateAccent(int beat) {
    accentsList[beat] = (accentsList[beat] + 1) % 4;
    notifyListeners();
  }

  void updateMeter(int index, int value){
    if (index == 0) {
      meter[0] = value;
      _accentsList = List.filled(value, 1);
    } else {
      meter[index] = value;
    }
    notifyListeners();

  }

  void updateSubdivision(Subdivision sub) {
    _subdivision = sub;
    notifyListeners();
  }





  double _totalAngle = (120 - 20)*8*pi/380;  //120 here represents the default tempo
  double get totalAngle => _totalAngle;
  Offset? _previousOffset;
  Offset? get previousOffset => _previousOffset;

  void setPreviousOffset(Offset? offset) {
    _previousOffset = offset;
  }

  void handleSpin(DragUpdateDetails details){
    if (_previousOffset == null) return;

    final currentOffset = details.localPosition;
    final center = Offset(50, 50); //TODO: Match with half size of the knob

    // Calculate the angle between the previous and current touch positions
    final previousVector = _previousOffset! - center;
    final currentVector = currentOffset - center;

    final previousAngle = previousVector.direction;
    final currentAngle = currentVector.direction;

    // Calculate the angle difference (delta)
    double delta = currentAngle - previousAngle;

    // Handle the wrap-around when crossing the -π to π boundary
    if (delta > pi) {
      delta -= 2 * pi;
    } else if (delta < -pi) {
      delta += 2 * pi;
    }
    // Update the total angle, clamping it between 0 and 8π

    _totalAngle = (totalAngle + delta).clamp(0.0, 8 * pi);

    final int tempo = (totalAngle / 8 / pi * 380 + 20.0).toInt(); // calculates a tempo between 20 and 400
    updateTempo(tempo);

    _previousOffset = currentOffset;
  }





}