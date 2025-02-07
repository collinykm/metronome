import "package:flutter/material.dart";
import 'package:audioplayers/audioplayers.dart';

mixin PlaySound {
  AudioPlayer player1 = AudioPlayer();
  AudioPlayer player2 = AudioPlayer();
  AudioPlayer player3 = AudioPlayer();

  Future initializePlayer() async {

    await player1.setSource(AssetSource('tick1.wav'));
    await player2.setSource(AssetSource('tick2.wav'));
    await player3.setSource(AssetSource('tick3.wav'));
    await player1.setReleaseMode(ReleaseMode.stop);
    await player2.setReleaseMode(ReleaseMode.stop);
    await player3.setReleaseMode(ReleaseMode.stop);
    // await player1.setPlayerMode(PlayerMode.lowLatency);
    // await player2.setPlayerMode(PlayerMode.lowLatency);
    // await player3.setPlayerMode(PlayerMode.lowLatency);

  }

  void playSound({required int intensity}) async {

    if (intensity != 0) {
      switch (intensity) {
        case 1:
          await player1.resume();
        case 2:
          await player2.resume();

        case 3:
          print("GOT HERE");
          await player3.resume();

      }
    }
  }

}