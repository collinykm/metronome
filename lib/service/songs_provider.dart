import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metronome_app/service/play_sound_mixin.dart';
import 'package:metronome_app/service/subdivision.dart';
import 'package:uuid/uuid.dart';
import "dart:math";

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

Song autumnLeaves = Song(songName: "Autumn Leaves", sectionsList: [
  Section(sectionName: "Head", bars: 1, tempo: 60, accentsList: [2, 1, 1, 1], meter: [4, 4], subdivision: allSubdivisionsMap[4]![0]),
  Section(sectionName: "Double time", bars: 1, tempo: 120, accentsList: [3, 1, 0, 1], meter: [4, 4], subdivision: allSubdivisionsMap[4]![0]),
]);

Song takeFive = Song(songName: "Take five", sectionsList: [
  Section(sectionName: "Head", bars: 32, tempo: 120, accentsList: [3, 1, 1, 2, 1], meter: [5, 4], subdivision: allSubdivisionsMap[4]![0]),
  Section(sectionName: "goofy part", bars: 64, tempo: 320, accentsList: [3, 1, 1, 2, 1], meter: [5, 4], subdivision: allSubdivisionsMap[4]![0]),
]);




class SongsProvider with ChangeNotifier, PlaySound{



  List<Song> _allSongs = [autumnLeaves, takeFive];

  Future<List<Song>> allSongs() async {
    final box = await Hive.openBox("AllSongs");
    return box.get("allSongs") ?? [autumnLeaves, takeFive];
  }


  Song getSong(String songId) {
    return _allSongs[_allSongs.indexWhere((song) => song.songId == songId)];
  }
  Section getSection(String songId, String sectionId) {
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    final Song songInQuestion = _allSongs[songIndex];
    final int sectionIndex = songInQuestion.sectionsList.indexWhere((section) => section.sectionId == sectionId);
    return songInQuestion.sectionsList[sectionIndex];
  }

  List<int> getAccentsList(String songId, String sectionId) {
    Section section = getSection(songId, sectionId);
    return section.accentsList;
  }

  List<int> getMeter(String songId, String sectionId) {
    Section section = getSection(songId, sectionId);
    return section.meter;
  }

  Subdivision getSubdivision(String songId, String sectionId) {
    Section section = getSection(songId, sectionId);
    return section.subdivision;
  }



  //things to do with playing a song
  bool _isPlaying = false;
  String _currentlyPlayingSongId = "";
  String get currentlyPlayingSongId => _currentlyPlayingSongId;
  void toggleCurrentlyPlayingSongId(String songId) {
    if( _currentlyPlayingSongId == songId) {
      _isPlaying = false;
      _currentlyPlayingSongId = "";
    } else {
      _currentlyPlayingSongId = songId;

    }
    notifyListeners();
  }

  void playSong() async {

    if (_isPlaying || _currentlyPlayingSongId == "") {
      return;
    }
    _isPlaying = true;
    initializePlayer();
    final int songIndex = _allSongs.indexWhere((song) => song.songId == _currentlyPlayingSongId);
    if (songIndex == -1) return;
    Song song = _allSongs[songIndex];

    for (Section section in song.sectionsList){
      int tempo = section.tempo;
      int bars = section.bars;
      List<int> accentsList = section.accentsList;
      List<int> meter = section.meter;
      List<int> subdivision = section.subdivision.subdivisionList;
      int currentPulse = 0;
      int totalPulses = bars * meter[0] * subdivision[0];
      int beatTime = (60 / tempo * pow(10, 6)).toInt();
      int pulseTime = beatTime ~/ subdivision[0] ;

      for (int i = 0; i < totalPulses; i++ ) {
        if (_isPlaying == false) return;
        int currentBeat = currentPulse ~/ subdivision[0];
        int pulseInBeat = currentPulse % subdivision[0] + 1;
        int intensity;
        if (currentPulse % subdivision[0] == 0) {
          intensity = accentsList[currentBeat] * subdivision[pulseInBeat];
        } else {
          intensity = subdivision[pulseInBeat];
        }

        playSound(intensity: intensity);
        currentPulse++;
        currentPulse = currentPulse % (meter[0] * subdivision[0]);
        await Future.delayed(Duration(microseconds: pulseTime));
      }
    }

    _isPlaying = false;
    _currentlyPlayingSongId = "";
    notifyListeners();


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

  void addSong(String songName) {
    _allSongs.add(Song(songName: songName));
    setSelectedSongId(_allSongs.last.songId);
    notifyListeners();
  }

  void removeSong(String id) {
    _allSongs.removeWhere((song) => song.songId == id);
    notifyListeners();
  }

  void changeSongName(String songId, String newName) {
    Song song = getSong(songId);
    song.updateName(newName);
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

    notifyListeners();
  }

  void removeSectionFromSong(String songId, String sectionId){
    Song song = getSong(songId);
    song.sectionsList.removeWhere((section) => section.sectionId == sectionId);
    notifyListeners();
  }

  void updateFieldInSection({required String songId, required String sectionId, required String toUpdate, required dynamic value}){
    Section section = getSection(songId, sectionId);
    switch (toUpdate) {
      case "name":
        section.updateName(value);
      case "bars":
        section.updateBars(value);
      case "tempo":
        section.updateTempo(value);
    }
    notifyListeners();

  }

  void updateAccent({required String songId, required String sectionId, required int beat}) {
    Section section = getSection(songId, sectionId);
    section.updateAccentsList(beat);
    notifyListeners();
  }

  void updateMeter({required String songId, required String sectionId, required int index, required int value}) {
    Section section = getSection(songId, sectionId);
    section.updateMeter(index, value);
    notifyListeners();
  }

  void updateSubdivision({required String songId, required String sectionId, required Subdivision sub}) {
    getSection(songId, sectionId).updateSubdivision(sub);
    notifyListeners();
  }
}




class Song{
  String songId = uuid.v4();
  String songName;
  List<Section> sectionsList;
  Song({required this.songName, List<Section>? sectionsList }) : sectionsList = sectionsList ?? [];


  void updateName(String newName){
    songName = newName;
  }

}

class Section{
  String sectionId = uuid.v4();
  String sectionName;
  int bars;
  int tempo;
  List<int> accentsList;
  List<int> meter;
  Subdivision subdivision;

  Section({
    required this.sectionName,
    required this.bars,
    required this.tempo,
    required this.accentsList,
    required this.meter,
    required this.subdivision,
  });




  void updateName(String newName){
    sectionName = newName;
  }
  void updateBars(int numBars) {
    bars = numBars;
  }
  void updateTempo(int newTempo) {
    tempo = newTempo;
  }
  void updateAccentsList(int beat) {
    accentsList[beat] = (accentsList[beat] + 1 ) % 4;
  }
  void updateMeter(int index, int value) {
    meter[index] = value;
  }
  void updateSubdivision(Subdivision sub) {
    subdivision = sub;
  }
}