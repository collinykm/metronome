import "package:flutter/material.dart";
import "package:metronome_app/screens/songs/section/section_popup.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {

  bool showSectionPopup = false;
  void togglePopup() {
    setState(() {
      showSectionPopup = !showSectionPopup;
    });
  }





  @override
  Widget build(BuildContext context) {

    String selectedSongId = Provider.of<SongsProvider>(context, listen: false).selectedSongId;
    Song song = Provider.of<SongsProvider>(context, listen: false).allSongs.firstWhere((song) => song.songId == selectedSongId);

    return Consumer<SongsProvider>(
      builder: (context, songsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(song.songName),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              songsProvider.addSectionToSong(song.songId);
            },
            child: Icon(Icons.add),
          ),

           
         body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (song.sectionsList.length == 0)
                          ElevatedButton(
                            onPressed: () {
                              songsProvider.addSectionToSong(song.songId);
                            },
                            child: Text(" + Add sections to this song"),
                          ),
                        
                        for (final section in song.sectionsList)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Text(section.sectionName),
                                  Text("Bars: ${section.bars}"),
                                  Text("Tempo: ${section.tempo}"),
                                  IconButton(
                                    onPressed: () {
                                      songsProvider.setSelectedSectionId(section.sectionId);
                                      songsProvider.toggleSectionPopup();
                                    },
                                    icon: Icon(Icons.edit))
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SectionPopup()
              ],
            ),
          ),


        );
      },
    );
  }
}
