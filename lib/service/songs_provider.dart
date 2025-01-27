import "package:flutter/material.dart";
import 'package:uuid/uuid.dart';


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
  Section(sectionName: "Head", bars: 32, tempo: 88, accentsList: [2, 1, 1, 1], meter: [4, 4], subdivision: [1, 1]),
  Section(sectionName: "Double time", bars: 64, tempo: 176, accentsList: [1, 1, 1, 1], meter: [4, 4], subdivision: [1, 1]),
]);

Song takeFive = Song(songName: "Take five", sectionsList: [
  Section(sectionName: "Head", bars: 32, tempo: 120, accentsList: [3, 1, 1, 2, 1], meter: [5, 4], subdivision: [1, 1]),
  Section(sectionName: "goofy part", bars: 64, tempo: 320, accentsList: [3, 1, 1, 2, 1], meter: [5, 4], subdivision: [1, 1]),
]);




class SongsProvider with ChangeNotifier{

  List<Song> _allSongs = [autumnLeaves, takeFive];
  List<Song> get allSongs => _allSongs;




  //Things to do with displaying the different pages
  bool showSectionPopup = false;
  String _selectedSongId = "";
  String _selectedSectionId = "";

  String get selectedSongId => _selectedSongId;
  String get selectedSectionId => _selectedSectionId;

  void toggleSectionPopup () {
    showSectionPopup = !showSectionPopup;
    notifyListeners();
  }
  void setSelectedSongId(String songId) {
    _selectedSongId = songId;
    print(_selectedSongId);
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

  void addSong(Song song) {
    _allSongs.add(song);
    notifyListeners();
  }

  void removeSong(String id) {
    _allSongs.removeWhere((song) => song.songId == id);
    notifyListeners();
  }

  void changeSongName(String songId, String newName) {
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    if (songIndex == -1) return;
    _allSongs[songIndex].updateName(newName);
    notifyListeners();
  }

  //methods to do with sections

  void addSectionToSong(String songId, Section section) {
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    if (songIndex == -1) return;

    _allSongs[songIndex].sectionsList.add(section);
    notifyListeners();
  }

  void removeSectionFromSong(String songId, String sectionId){
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    if (songIndex == -1) return;
    final Song songInQuestion = _allSongs[songIndex];
    final int sectionIndex = songInQuestion.sectionsList.indexWhere((section) => section.sectionId == sectionId);
    if (sectionIndex == -1) return;
    songInQuestion.sectionsList.removeWhere((section) => section.sectionId == sectionId);
    notifyListeners();
  }

  void updateFieldInSection(String songId, String sectionId, String toUpdate, dynamic value){
    final int songIndex = _allSongs.indexWhere((song) => song.songId == songId);
    if (songIndex == -1) return;
    final Song songInQuestion = _allSongs[songIndex];
    final int sectionIndex = songInQuestion.sectionsList.indexWhere((section) => section.sectionId == sectionId);
    if (sectionIndex == -1) return;
    final Section section = songInQuestion.sectionsList[sectionIndex];
    switch (toUpdate) {
      case "name":
        section.updateName(value);
      case "bars":
        section.updateBars(value);
      case "tempo":
        section.updateTempo(value);
      case "accent":
        section.updateAccentsList(value);
      case "meter":
        section.updateMeter(value);
      case "subdivision":
        section.updateSubdivision(value);
    }
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
  List<int> subdivision;

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
  void updateAccentsList(List<int> newAccentList) {
    accentsList = newAccentList;
  }
  void updateMeter(List<int> newMeter) {
    meter = newMeter;
  }
  void updateSubdivision(List<int> newSubdivision) {
    subdivision = newSubdivision;
  }
}