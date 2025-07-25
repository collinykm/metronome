import "package:flutter/material.dart";
import "package:metronome_app/components/popup_dialogue.dart";
import "package:metronome_app/components/popup_input_dialogue.dart";
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
    Song song = Provider.of<SongsProvider>(context, listen: false).allSongs().firstWhere((song) => song.songId == selectedSongId);

    return Consumer<SongsProvider>(
      builder: (context, songsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              child: Text(song.songName),
              onTap: () async {
                TextEditingController controller = TextEditingController(text: song.songName);

                showInputDialogue(context: context,
                  handleSubmit: () {
                    songsProvider.changeSongName(songsProvider.selectedSongId, controller.text.trim());
                    Navigator.pop(context);
                  },
                  title: "Rename this song",
                  hintText: "Rename",
                  controller: controller,
                  confirmText: "Done",
                );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  songsProvider.playSong(song.songId);
                },
                icon: song.songId == songsProvider.currentlyPlayingSongId ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              ),
              //delete song button
              IconButton(
                  onPressed: () async {
                    bool confirm = await showPopupDialogue(context, "Delete Song", "'${song.songName}' cannot be recovered", "Delete");
                    if (confirm) {
                      Navigator.pop(context);
                      songsProvider.removeSong(song.songId);
                    }
                  },
                  icon: Icon(Icons.delete)
              )

            ],
          ),

          floatingActionButton: Visibility(
            visible: !songsProvider.showSectionPopup,
            child: FloatingActionButton(
              onPressed: () {
                songsProvider.addSectionToSong(song.songId);
              },
              child: Icon(Icons.add),
            ),
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
                        if (song.sectionsList.isEmpty)
                          ElevatedButton(
                            onPressed: () {
                              songsProvider.addSectionToSong(song.songId);
                            },
                            child: Text(" + Add sections to this song"),
                          ),
                        
                        for (final section in song.sectionsList)
                          Dismissible(
                            key: Key(section.sectionId),
                            confirmDismiss: (direction) async {
                              return showPopupDialogue(context, "Section '${section.sectionName}' cannot be recovered",
                                  "Section '${section.sectionName}' cannot be recovered", "Delete");

                            },
                            onDismissed: (direction) {
                              songsProvider.removeSectionFromSong(song.songId, section.sectionId);
                            },
                            background: Container(

                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                            child: Card(
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
