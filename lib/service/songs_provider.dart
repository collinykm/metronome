import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metronome_app/service/subdivision.dart';
import 'package:uuid/uuid.dart';
import "dart:math";
import 'package:flutter/services.dart';
import 'dart:ffi';
part 'songs_provider.g.dart';


final uuid = Uuid();



/*
BASIC LOGIC:

users will create a big ass add button which will call addSong() in AllSongs.
This will add an untitled song.

When they click open this song(which can be found through the id), they'll see that the
  sections part in Song is empty.
Users can click another big ass button to create a section. This will not call addSection() yet.
UI will popup showing options for adding a song. Any changes will be saved to temporary variables
Once they press a big ass save button, addSection will be called with those temporary variables passed in.

If they want to edit a section, they'll press an edit button, which will pass the section's id to this model.
I can find the section in the Song's sectionsList and then call the respective update functions.


*/

Song sampleSong = Song(songName: "Sample", sectionsList: [
  Section(sectionName: "Section 1", bars: 4, tempo: 60, accentsList: [2, 1, 1, 1], meter: [4, 4], subdivision: allSubdivisionsMap[4]![0]),
  Section(sectionName: "Section 2", bars: 8, tempo: 120, accentsList: [3, 1, 1], meter: [3, 4], subdivision: allSubdivisionsMap[4]![0]),
]);





class SongsProvider with ChangeNotifier{
  final MethodChannel methodChannel = MethodChannel('metronome_method_channel');
  final Box _songsBox = Hive.box('songsBox');


  List<Song> _allSongs = [sampleSong];
  List<Song> allSongs() {
    if(_songsBox.get("songs") == null){
      print("songsBox was null");
      return _allSongs;
    }
    _allSongs = List<Song>.from(_songsBox.get("songs"));
    return _allSongs;
  }




  Song getSong(String songId) {
    return _allSongs[_allSongs.indexWhere((song) => song.songId == songId)];
  }
  Section? getSection(String songId, String sectionId) {
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    final Song songInQuestion = _allSongs[songIndex];
    final int sectionIndex = songInQuestion.sectionsList.indexWhere((section) => section.sectionId == sectionId);
    if (sectionIndex == -1) {
      return null;
    }
    return songInQuestion.sectionsList[sectionIndex];
  }

  List<int>? getAccentsList(String songId, String sectionId) {
    Section? section = getSection(songId, sectionId);
    return section?.accentsList;
  }

  List<int>? getMeter(String songId, String sectionId) {
    Section? section = getSection(songId, sectionId);

    return section?.meter;
  }

  Subdivision? getSubdivision(String songId, String sectionId) {
    Section? section = getSection(songId, sectionId);
    return section?.subdivision;
  }



  //things to do with playing a song
  bool _isPlaying = false;
  String _currentlyPlayingSongId = "";
  String get currentlyPlayingSongId => _currentlyPlayingSongId;



  void playSong(String songId) async {

    if (_isPlaying) {
      print("uhhh");
      _isPlaying = false;
      await methodChannel.invokeMethod("pauseSong");

      _currentlyPlayingSongId = "";
      notifyListeners();
      return;

    }
    _currentlyPlayingSongId = songId;

    _isPlaying = true;
    notifyListeners();

    final int songIndex = _allSongs.indexWhere((song) => song.songId == _currentlyPlayingSongId);
    if (songIndex == -1) return;
    Song song = _allSongs[songIndex];
    print("got here");
    startEventChannelListening();
    await methodChannel.invokeMethod("playSong", song.toMap());

  }

  final EventChannel eventChannel = EventChannel('metronome_event_channel');
  void startEventChannelListening() {
    eventChannel.receiveBroadcastStream().listen((event) {
      if (event["type"] == "alert"){
        if (event["message"] == "song ended") {
          print("song ended");
          _isPlaying = false;
          _currentlyPlayingSongId = "";
          notifyListeners();
        }
      }


    }, onError: (e) {
      print(e);
    });
  }



  //Things to do with displaying the different pages for songs and popups for sections

  bool _showSectionPopup = false;
  bool _isMeterPopupVisible = false;
  bool _isSubdivisionPopupVisible = false;
  String _selectedSongId = "";
  String _selectedSectionId = "";
  bool get showSectionPopup => _showSectionPopup;
  bool get isMeterPopupVisible => _isMeterPopupVisible;
  bool get isSubdivisionPopupVisible => _isSubdivisionPopupVisible;
  String get selectedSongId => _selectedSongId;
  String get selectedSectionId => _selectedSectionId;

  void toggleSectionPopup ({bool? setFalse}) {
    if (setFalse == null) {
      _showSectionPopup = !_showSectionPopup;
      notifyListeners();
    } else {
      _showSectionPopup = false;
    }

  }
  void toggleMeterPopup ({bool? setFalse}) {
    if (setFalse == null) {
      _isMeterPopupVisible = !_isMeterPopupVisible;
      notifyListeners();
    } else {
      _isMeterPopupVisible = false;
    }

  }
  void toggleSubdivisionPopup({bool? setFalse}) {
    if (setFalse == null) {
      _isSubdivisionPopupVisible = !_isSubdivisionPopupVisible;
      notifyListeners();
    } else {
      _isSubdivisionPopupVisible = false;
    }

  }
  void setSelectedSongId(String songId) {
    _selectedSongId = songId;
    notifyListeners();
  }
  void setSelectedSectionId(String sectionId) {
    _selectedSectionId = sectionId;
    notifyListeners();
  }
  void clearSongId(){
    _selectedSongId = "";
  }
  void clearSectionId(){
    _selectedSectionId = "";
  }


  //methods to do with songs

  void addSong(String songName) async {
    _allSongs.add(Song(songName: songName));
    addSectionToSong(_allSongs.last.songId);
    setSelectedSongId(_allSongs.last.songId);

    await _songsBox.put('songs', _allSongs);
    notifyListeners();
  }

  void removeSong(String id) {
    if (_isPlaying) {
      playSong(id);
    }
    _allSongs.removeWhere((song) => song.songId == id);
    _selectedSongId = "";
    _selectedSectionId = "";

    _songsBox.put('songs', _allSongs);
    notifyListeners();
  }

  void changeSongName(String songId, String newName) {
    Song song = getSong(songId);
    song.updateName(newName);

    _songsBox.put('songs', _allSongs);
    notifyListeners();
  }

  //methods to do with sections

  void addSectionToSong(String songId) {
    Song song = getSong(songId);
    song.sectionsList.add(
        Section(sectionName: "Section ${song.sectionsList.length + 1}", bars: 8, tempo: 120, accentsList: [1, 1, 1, 1], meter: [4,4], subdivision: allSubdivisionsMap[4]![0])
    );
    setSelectedSectionId(song.sectionsList.last.sectionId);
    toggleSectionPopup();

    _songsBox.put('songs', _allSongs);
    notifyListeners();
  }

  void removeSectionFromSong(String songId, String sectionId){
    Song song = getSong(songId);
    song.sectionsList.removeWhere((section) => section.sectionId == sectionId);
    _selectedSectionId = "";

    _songsBox.put('songs', _allSongs);
    notifyListeners();
  }

  void updateFieldInSection({required String songId, required String sectionId, required String toUpdate, required dynamic value}){
    Section? section = getSection(songId, sectionId);
    if (section == null) {
      throw Exception("section not found");
    }
    switch (toUpdate) {
      case "name":
        section.updateName(value);
      case "bars":
        section.updateBars(value);
      case "tempo":
        section.updateTempo(value);
    }

    _songsBox.put('songs', _allSongs);
    notifyListeners();

  }
  void updateAccent({required String songId, required String sectionId, required int beat}) {
    Section? section = getSection(songId, sectionId);
    if (section != null) {
      section.updateAccentsList(beat);
      _songsBox.put('songs', _allSongs);
      notifyListeners();
    } else {
      throw Exception("section not found");
    }
  }

  void updateMeter({required String songId, required String sectionId, required int index, required int value}) {
    Section? section = getSection(songId, sectionId);
    if (section != null) {
      section.updateMeter(index, value);
      _songsBox.put('songs', _allSongs);
      notifyListeners();
    } else {
      throw Exception("section not found");
    }
  }

  void updateSubdivision({required String songId, required String sectionId, required Subdivision sub}) {
    Section? section = getSection(songId, sectionId);
    if (section != null) {
      section.updateSubdivision(sub);
      _songsBox.put('songs', _allSongs);
      notifyListeners();
    } else {
      throw Exception("section not found");
    }
  }

}







@HiveType(typeId: 0)
class Song {
  @HiveField(0)
  String songId;

  @HiveField(1)
  String songName;

  @HiveField(2)
  List<Section> sectionsList;

  Song({required this.songName, List<Section>? sectionsList})
      : sectionsList = sectionsList ?? [],
        songId = uuid.v4();

  void updateName(String newName) {
    songName = newName;
  }

  Map<String, dynamic> toMap() {
    return {
      "songId": songId,
      "songName": songName,
      "sectionsList": sectionsList.map((s) => s.toMap()).toList()
    };
  }


}



@HiveType(typeId: 1)
class Section {
  @HiveField(0)
  String sectionId;

  @HiveField(1)
  String sectionName;

  @HiveField(2)
  int bars;

  @HiveField(3)
  int tempo;

  @HiveField(4)
  List<int> accentsList;

  @HiveField(5)
  List<int> meter;

  @HiveField(6)
  Subdivision subdivision;

  Section({
    required this.sectionName,
    required this.bars,
    required this.tempo,
    required this.accentsList,
    required this.meter,
    required this.subdivision,
  }) : sectionId = uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      "sectionId": sectionId,
      "sectionName": sectionName,
      "bars": bars,
      "tempo": tempo,
      "accentsList": accentsList,
      "meter": meter,
      "subdivision": subdivision.subdivisionList
    };
  }

  void updateName(String newName) {
    sectionName = newName;
  }

  void updateBars(int numBars) {
    bars = numBars;
  }

  void updateTempo(int newTempo) {
    tempo = newTempo;
  }

  void updateAccentsList(int beatIndex) {
    accentsList[beatIndex] = (accentsList[beatIndex] + 1) % 4;
  }

  void updateMeter(int index, int value) {
    if (index == 0) {
      accentsList = List.filled(value, 1);
    }
    else if (index == 1){
      int currentlySelectedIndex = allSubdivisionsMap[meter[1]]!.indexOf(subdivision);
      updateSubdivision(allSubdivisionsMap[value]![currentlySelectedIndex]);
    }
    meter[index] = value;
  }

  void updateSubdivision(Subdivision sub) {
    subdivision = sub;
  }
}