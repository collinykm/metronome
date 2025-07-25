import "package:flutter/material.dart";
import "package:metronome_app/components/popup_dialogue.dart";
import "package:metronome_app/components/popup_input_dialogue.dart";
import "package:metronome_app/screens/songs/song_page.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class AllSongsPage extends StatefulWidget {
  const AllSongsPage({super.key});

  @override
  State<AllSongsPage> createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SongsProvider>(
      builder: (context, songsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Custom Songs"),

          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              TextEditingController controller = TextEditingController(text: "Untitled");

              showInputDialogue(context: context,
                  handleSubmit: () {
                    songsProvider.addSong(controller.text.trim());
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SongPage())
                    );
                  },
                  title: "Name this song",
                  hintText: "New name",
                  controller: controller,
                  confirmText: "Create",
              );

            },
            child: Icon(Icons.add),
          ),


          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final song in songsProvider.allSongs())
                  Container(
                    margin: EdgeInsets.all(40),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),


                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(song.songName),

                        //the play button
                        IconButton(
                          onPressed: () {
                            songsProvider.playSong(song.songId);
                          },
                          icon: song.songId == songsProvider.currentlyPlayingSongId ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                        ),


                        //the edit button
                        IconButton(
                          onPressed: (){
                            songsProvider.setSelectedSongId(song.songId);
                            songsProvider.setSelectedSectionId(song.sectionsList[0].sectionId);
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => SongPage())
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        );
      }
    );
  }
}
