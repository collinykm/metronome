import "package:flutter/material.dart";
import "package:metronome_app/components/app_icon_button.dart";
import "package:metronome_app/components/popup_dialogue.dart";
import "package:metronome_app/components/popup_input_dialogue.dart";
import "package:metronome_app/screens/songs/song_page.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:provider/provider.dart";

import "../../theme/typography.dart";

class AllSongsPage extends StatefulWidget {
  const AllSongsPage({super.key});

  @override
  State<AllSongsPage> createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> {

  String query = "";




  @override
  Widget build(BuildContext context) {
    return Consumer<SongsProvider>(
      builder: (context, songsProvider, child) {
        final filteredSongs = songsProvider.allSongs().where((song) => song.songName.toLowerCase().contains(query.toLowerCase().trim()));
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
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
            child: AppIcons.add(color: AppColors.accent1),
          ),


          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TitleText("My Songs"),
                  const SizedBox(height: 20,),
                  //search bar
                  TextField(
                    decoration: InputDecoration(
                      label: BodyText("Search"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.accent1)
                      ),
                      prefixIcon: AppIcons.search(),

                    ),
                    cursorColor: AppColors.accent1,
                    style: TextStyles.body,
                    onChanged: (newQuery) {
                      setState(() {
                        query = newQuery;
                      });
                    },
                  ),


                  const SizedBox(height: 30,),



                  //Region: list of songs
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (final song in filteredSongs)
                            Container(
                              margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primary,
                              ),


                              child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(song.songName, style: TextStyles.title.copyWith(fontSize: 16)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //the play button
                                    AppIconButton(
                                      onPressed: () {
                                        songsProvider.playSong(song.songId);
                                      },
                                      icon: song.songId == songsProvider.currentlyPlayingSongId ? AppIcons.pause() : AppIcons.play(),
                                    ),


                                    //the edit button
                                    AppIconButton(
                                      onPressed: (){
                                        songsProvider.setSelectedSongId(song.songId);
                                        songsProvider.setSelectedSectionId(song.sectionsList[0].sectionId);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => SongPage())
                                        );
                                      },
                                      icon: AppIcons.edit(color: AppColors.accent1),
                                    ),
                                  ],
                                ),
                              )


                            ),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
          )
        );
      }
    );
  }
}
