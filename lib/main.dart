
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metronome_app/screens/metronome/metronome_page.dart';
import 'package:metronome_app/screens/songs/all_songs_page.dart';
import 'package:metronome_app/screens/tuner/tuner_page.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/service/songs_provider.dart';
import 'package:metronome_app/service/subdivision.dart';
import 'package:metronome_app/service/tuner_provider.dart';
import 'package:metronome_app/theme/colors.dart';
import 'package:metronome_app/theme/icons.dart';
import 'package:metronome_app/theme/typography.dart';
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
      debugShowCheckedModeBanner: false,
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
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1
              )
            )
          ),
        child: NavigationBar(
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPageIndex = index;
            });
          },
          backgroundColor: AppColors.background,
          indicatorColor: AppColors.accent1,
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),


          destinations: <Widget>[
            NavigationDestination(icon: AppIcons.metronome(), label: "Metronome"),
            NavigationDestination(icon: AppIcons.tuner(), label: "Tuner"),
            NavigationDestination(icon: AppIcons.song(), label: "Songs"),
            NavigationDestination(icon: AppIcons.settings(), label: "Settings"),
          ],
        ),
      ),

      body: <Widget>[
        MetronomePage(),
        TunerPage(),
        AllSongsPage(),
        BodyText("Settings Page"),

      ][selectedPageIndex],
    );
  }
}


