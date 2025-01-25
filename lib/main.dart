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
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),

      body: <Widget>[
        MetronomePage(),
        Text("Tuner Page"),
        Text("Settings Page"),
      ][selectedPageIndex],
    );
  }
}




