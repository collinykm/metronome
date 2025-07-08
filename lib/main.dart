
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metronome_app/screens/metronome/metronome_page.dart';
import 'package:metronome_app/screens/songs/all_songs_page.dart';
import 'package:metronome_app/screens/tuner/tuner_page.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/service/play_sound_mixin.dart';
import 'package:metronome_app/service/songs_provider.dart';
import 'package:metronome_app/service/subdivision.dart';
import 'package:metronome_app/service/tuner_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';





void main() async{


  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(SubdivisionAdapter());
  await Hive.openBox('songsBox');





  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MetronomeProvider()),
      ChangeNotifierProvider(create: (_) => SongsProvider()),
      ChangeNotifierProvider(create: (_) => TunerProvider()),
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
  void initState() {
    super.initState();
    initSoLoud();

  }

  Future initSoLoud() async {
    try {
      await SoLoud.instance.init(channels: Channels.mono, bufferSize: 512);
      await Provider.of<MetronomeProvider>(context, listen: false).initializePlayer();
    } catch (e) {
      debugPrint("SoLoud init error: $e");
    }
  }

  @override
  void dispose() {
    SoLoud.instance.deinit();
    Provider.of<MetronomeProvider>(context, listen: false).disposePlayer();
    super.dispose();
  }

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
        TunerPage(),
        AllSongsPage(),
        Text("Settings Page"),

      ][selectedPageIndex],
    );
  }
}


