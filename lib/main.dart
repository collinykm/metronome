import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/metronome_page.dart';
import 'package:metronome_app/screens/songs/all_songs_page.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/service/play_metronome_provider.dart';
import 'package:metronome_app/service/songs_provider.dart';
import 'package:provider/provider.dart';



void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MetronomeProvider()),
      ChangeNotifierProvider(create: (_) => SongsProvider()),
      ChangeNotifierProvider(create: (_) => PlayMetronomeProvider())
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
        Test()
      ][selectedPageIndex],
    );
  }
}




class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool showPopup = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background to detect taps outside the popup
          if (showPopup)
            GestureDetector(
              onTap: () {
                setState(() {
                  showPopup = false; // Hide the popup when tapping outside
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3), // Semi-transparent background
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Text and Button
          Positioned(
            top: 100, // Adjust as needed
            right: 20, // Adjust as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Above the Button"), // Text above the button
                IconButton(
                  onPressed: () {
                    setState(() {
                      showPopup = !showPopup; // Toggle the popup
                    });
                  },
                  icon: Icon(Icons.open_in_full),
                ),
                Text("Below the Button"), // Text below the button
              ],
            ),
          ),

          // Popup
            AnimatedPositioned(
              right: showPopup ? 0 : -200, // Slide in from the right
              duration: Duration(milliseconds: 300),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text("Popup Content"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

