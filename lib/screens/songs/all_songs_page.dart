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
    return Scaffold(
      appBar: AppBar(
        title: Text("Custom Songs"),
      ),

      body: Consumer<SongsProvider>(
          builder: (context, songsProvider, child) {
            return Column(
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
                          IconButton(
                              onPressed: (){
                                print(song.songId);
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
            );
          }
      ),
    );
  }
}
