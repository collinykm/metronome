import "package:flutter/material.dart";
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class Metronome with ChangeNotifier {

  int _tempo = 120;
  List<int> _accentsList = [3, 1, 2, 1];
  List<int> _subdivision = [1, 1];
  List<int> _meter = [4, 4];
  bool _isPlaying = false;


  AudioPlayer player1 = AudioPlayer();
  AudioPlayer player2 = AudioPlayer();
  AudioPlayer player3 = AudioPlayer();



  int get tempo => _tempo;
  List<int> get accentsList => _accentsList;
  List<int> get subdivision => _subdivision;
  List<int> get meter => _meter;
  bool get isPlaying => _isPlaying;
  double initialAngle() => (_tempo - 20)*8*pi/380;





  void Pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  void Play() async {
    if (isPlaying) {
      return;
    }
    _isPlaying = true;

    await player1.setSource(AssetSource('tick1.wav'));
    await player2.setSource(AssetSource('tick2.wav'));
    await player3.setSource(AssetSource('tick3.wav'));
    await player1.setReleaseMode(ReleaseMode.stop);
    await player2.setReleaseMode(ReleaseMode.stop);
    await player3.setReleaseMode(ReleaseMode.stop);
    int currentPulse = 0;

    while (isPlaying) {
      int beatTime = (60 / _tempo * pow(10, 6)).toInt();
      int pulseTime = beatTime ~/ subdivision[0];
      tickInTime(currentPulse);
      currentPulse++;
      currentPulse = currentPulse % (meter[0] * subdivision[0]);
      await Future.delayed(Duration(microseconds: pulseTime));
    }
  }

  void tickInTime(int currentPulse) {
    int currentBeat = currentPulse ~/ subdivision[0];
    int pulseInBeat = currentPulse % subdivision[0] + 1;
    int intensity = _accentsList[currentBeat] * subdivision[pulseInBeat];
    playSound(intensity: intensity);
    currentPulse++;
    currentPulse = currentPulse % (meter[0] * subdivision[0]);
  }

  void playSound({required int intensity}) async {
    if (intensity != 0) {
      switch (intensity) {
        case 1:
          await player1.resume();
        case 2:
          await player2.resume();
        case 3:
          await player3.resume();
      }
    }
  }




  void updateTempo(int tempo) {
    _tempo = tempo;
    notifyListeners();
  }

  void updateAccent(int beat) {
    accentsList[beat] = (accentsList[beat] + 1) % 4;
    notifyListeners();
  }

  void updateMeterBeats(int numBeats){
    meter[0] = numBeats;
    _accentsList = List.filled(numBeats, 1);
    notifyListeners();

  }
  void updateMeterValue(int beatValue){
    meter[1] = beatValue;
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