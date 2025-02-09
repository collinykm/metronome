import 'dart:collection';

import "package:flutter/material.dart";
import 'package:audioplayers/audioplayers.dart';


import 'package:flutter_soloud/flutter_soloud.dart';

mixin PlaySound {

  AudioSource? tick1;
  AudioSource? tick2;
  AudioSource? tick3;
  SoundHandle? tick1Handle;
  SoundHandle? tick2Handle;
  SoundHandle? tick3Handle;


  void initializePlayer() {

    SoLoud.instance.loadAsset('assets/audio/tick1-short.wav').then((value) async {
      /// start playing the tick in a paused state, so it can be
      /// unpaused/paused in the `Timer` callback.
      tick1 = value;
      tick1Handle = await SoLoud.instance.play(tick1!, paused: true);
      await SoLoud.instance.loadAsset('assets/audio/tick2.wav').then((value) async {
        /// start playing the tick in a paused state, so it can be
        /// unpaused/paused in the `Timer` callback.
        tick2 = value;
        tick2Handle = await SoLoud.instance.play(tick2!, paused: true);
        await SoLoud.instance.loadAsset('assets/audio/tick3.wav').then((value) async {
          tick3 = value;
          tick3Handle = await SoLoud.instance.play(tick3!, paused: true);
        });
      });
    });
  }



  Future playSound({required int intensity}) async {

    if (intensity != 0) {
      switch (intensity) {
        case 1:
          final stopwatch = Stopwatch();
          stopwatch.start();
          await SoLoud.instance.play(tick1!);
          stopwatch.stop();
          print(stopwatch.elapsedMilliseconds);

          break;
        case 2:
          SoLoud.instance.play(tick2!);
          break;
        case 3:
          SoLoud.instance.play(tick3!);
          break;

      }
    }
  }

}