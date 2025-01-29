import "package:flutter/material.dart";
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Name this song"),
                      content: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "New name",
                        ),
                      ),
                      actions: [
                        //cancel button
                        ElevatedButton(
                            onPressed: () {Navigator.pop(context);}, child: Text("Cancel")
                        ),
                        //Create button
                        ElevatedButton(
                          onPressed: () {
                            songsProvider.addSong(controller.text.trim());
                            Navigator.pop(context);
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => SongPage())
                            );
                          },
                          child: Text("Create"),
                        ),
                      ],
                    );
                  }
                );

              },
              child: Icon(Icons.add),
            ),

            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final song in songsProvider.allSongs)
                    Container(
                      margin: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
              
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(song.songName),
              
                            //the play button
                            IconButton(
                              onPressed: () {
                                songsProvider.toggleCurrentlyPlayingSongId(song.songId);
                                songsProvider.playSong();
                              },
                              icon: song.songId == songsProvider.currentlyPlayingSongId ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                            ),
              

                            //the edit button
                            IconButton(
                              onPressed: (){
                                songsProvider.setSelectedSongId(song.songId);
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => SongPage())
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
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
