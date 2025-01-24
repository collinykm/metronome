import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/metronome_page.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Metronome()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: MetronomePage(),
        ),
      ),
    ),
  ));
}

