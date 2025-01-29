import "package:flutter/material.dart";
import 'package:audioplayers/audioplayers.dart';
import "dart:math";


class PlayMetronomeProvider with ChangeNotifier {
  AudioPlayer player1 = AudioPlayer();
  AudioPlayer player2 = AudioPlayer();
  AudioPlayer player3 = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;


  void Pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  void Play({required int tempo, required List<int> subdivision, required List<int> meter, required List<int> accentsList}) async {
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
      int beatTime = (60 / tempo * pow(10, 6)).toInt();
      int pulseTime = beatTime ~/ subdivision[0];
      tickInTime(currentPulse, subdivision, accentsList, meter);
      currentPulse++;
      currentPulse = currentPulse % (meter[0] * subdivision[0]);
      await Future.delayed(Duration(microseconds: pulseTime));
    }
  }

  void tickInTime(int currentPulse, List<int> subdivision, List<int> accentsList, List<int> meter) {
    int currentBeat = currentPulse ~/ subdivision[0];
    int pulseInBeat = currentPulse % subdivision[0] + 1;
    int intensity = accentsList[currentBeat] * subdivision[pulseInBeat];
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

}