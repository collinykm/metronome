import 'dart:async';
import 'dart:ffi';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:metronome_app/screens/metronome/accent_selector.dart';
import 'dart:math';


import 'package:metronome_app/service/subdivision.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'songs_provider.dart';


class MetronomeProvider with ChangeNotifier{
  final MethodChannel methodChannel = MethodChannel('metronome_method_channel');

  int _tempo = 120;
  List<int> _accentsList = [1, 1, 1, 1];
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
    ex. i want triplets, them subdivision[0] is 3. if i want sixteenths, then subdivision[0] is 4;
    the following subdivision[0] number of numbers represents if each of the divisions are silent or not. 0 means silent, 1 means play
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
    await methodChannel.invokeMethod("pauseMetronome");
  }

  void Play() async {
    print("I was invoked");
    if (_isPlaying) {
      return;
    }
    _isPlaying = true;
    await methodChannel.invokeMethod("playMetronome");

  }







  void updateTempo(int tempo) async {
    _tempo = tempo;
    notifyListeners();
    await methodChannel.invokeMethod("updateTempo", tempo);
  }

  void updateAccent(int beat) async {
    accentsList[beat] = (accentsList[beat] + 1) % 4;
    notifyListeners();
    await methodChannel.invokeMethod("updateAccent", accentsList);
  }

  void updateMeter(int index, int value) async {
    if (index == 0) {
      meter[0] = value;
      _accentsList = List.filled(value, 1);
    } else {
      meter[index] = value;
    }
    notifyListeners();
    await methodChannel.invokeMethod("updateMeter", meter);
    await methodChannel.invokeMethod("updateAccent", accentsList);

  }

  void updateSubdivision(Subdivision sub) async {
    _subdivision = sub;
    notifyListeners();
    await methodChannel.invokeMethod("updateSubdivision", subdivisionList);
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