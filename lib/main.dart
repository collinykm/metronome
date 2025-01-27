import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/metronome_page.dart';
import 'package:metronome_app/screens/songs/all_songs_page.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/service/songs_provider.dart';
import 'package:provider/provider.dart';


import 'package:record/record.dart';
import 'package:fftea/fftea.dart'; // Cross-platform FFT package
import 'dart:typed_data';
void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Metronome()),
      ChangeNotifierProvider(create: (_) => SongsProvider())
    ],
    child: MaterialApp(
      home: NavBarApp()
      ),
    ),
  );
}



class NavBarApp extends StatefulWidget {
  const NavBarApp({super.key});

  @override
  State<NavBarApp> createState() => _NavBarAppState();
}

class _NavBarAppState extends State<NavBarApp> {
  int selectedPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedPageIndex = index;
          });
        },

        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.timer), label: "Metronome"),
          NavigationDestination(icon: Icon(Icons.tune), label: "Tuner"),
          NavigationDestination(icon: Icon(Icons.music_note), label: "Songs"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),

      body: <Widget>[
        MetronomePage(),
        Text("Tuner Page"),
        AllSongsPage(),
        Text("Settings Page"),
      ][selectedPageIndex],
    );
  }
}





