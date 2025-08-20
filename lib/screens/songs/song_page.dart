import "package:flutter/material.dart";
import "package:metronome_app/components/app_icon_button.dart";
import "package:metronome_app/components/app_text_button.dart";
import "package:metronome_app/components/filtered_image.dart";
import "package:metronome_app/components/popup_dialogue.dart";
import "package:metronome_app/components/popup_input_dialogue.dart";
import "package:metronome_app/components/selector_button.dart";
import "package:metronome_app/screens/songs/section/song_accent_selector_logic.dart";
import "package:metronome_app/screens/songs/section/song_meter_selector_logic.dart";
import "package:metronome_app/screens/songs/section/song_subdivision_selector_logic.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:metronome_app/theme/icons.dart";
import "package:provider/provider.dart";
import "package:string_validator/string_validator.dart";

import "../../theme/colors.dart";
import "../../theme/typography.dart";


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
            backgroundColor: AppColors.background,
            leading:AppIconButton(
              icon:AppIcons.arrowLeft(),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            title: GestureDetector(
              child: TitleText(song.songName),
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
              AppIconButton(
                onPressed: () {
                  songsProvider.playSong(song.songId);
                },
                icon: song.songId == songsProvider.currentlyPlayingSongId ? AppIcons.pause() : AppIcons.play(),
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
                  icon: AppIcons.trash()
              )

            ],
          ),

          floatingActionButton: Visibility(
            child: FloatingActionButton(
              onPressed: () {
                songsProvider.addSectionToSong(song.songId);
              },
              backgroundColor: AppColors.primary,
              child: AppIcons.add(color: AppColors.accent1),
            ),
          ),


          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: Container(color: AppColors.background,)),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30,),
                      if (song.sectionsList.isEmpty)
                        AppTextButton(
                          onPressed: () {
                            songsProvider.addSectionToSong(song.songId);
                          },
                          textWidget: BodyText(" + Add sections to this song"),
                        ),
          
                     //Region: the card for each section
                      for (Section section in song.sectionsList)
                        Container(
                         width: 350,
                         padding: EdgeInsets.symmetric(vertical: 30),
                         margin: EdgeInsets.only(bottom: 30),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(
                             color: Colors.black
                           )
                         ),
                         child: Column(
                           children: [
                             //Region: updating section name and delete button
                             Stack(
                               alignment: Alignment.center,
                               children: [
                                 Align(
                                   alignment: Alignment.bottomCenter,
                                   child: TextButton(
                                     onPressed: () {
                                       TextEditingController controller = TextEditingController(text: section.sectionName);
                                       showInputDialogue(context: context,
                                         handleSubmit: () {
                                           String text = controller.text.trim();
                                           songsProvider.updateFieldInSection(songId: song.songId, sectionId: section.sectionId, toUpdate: "name", value: text);
                                           Navigator.pop(context);
                                         },
                                         title: "Name this section",
                                         hintText: "ex. Part A",
                                         controller: controller,
                                         confirmText: "Done",
                                       );
                                     },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size(50, 36),                   // no min height/width
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                     child: TitleText(section.sectionName),
                                   ),
                                 ),
                                 //Region: delete section button
                                 Align(
                                   alignment: Alignment.centerRight,
                                   child: AppIconButton(
                                       onPressed: () async {
                                         bool confirm = await showPopupDialogue(context, "Delete Section", "'${section.sectionName}' cannot be recovered", "Delete");
                                         if (confirm) {
                                           setState(() {
          
                                           });
                                           songsProvider.removeSectionFromSong(song.songId, section.sectionId);
                                         }
                                       },
                                     icon: AppIcons.trash()
                                   ),
                                 ),
                               ],
                             ),
                             //Region: num bars and tempo
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 //Region: updating num bars
                                 AppTextButton(
                                     onPressed: () {
                                       songsProvider.setSelectedSectionId(section.sectionId);
                                       TextEditingController controller = TextEditingController(text: section.bars.toString());
                                       showInputDialogue(context: context,
                                         handleSubmit: () {
                                           String text = controller.text.trim();
                                           if (isInt(text)) {
                                             int bars = int.parse(text);
                                             songsProvider.updateFieldInSection(
                                                 songId: songsProvider.selectedSongId,
                                                 sectionId: songsProvider.selectedSectionId,
                                                 toUpdate: "bars",
                                                 value: bars
                                             );
                                           } else {
                                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                               content: const BodyText(
                                                   "Input can only contain numbers"),
                                               showCloseIcon: true,
                                               duration: const Duration(seconds: 2),
                                               backgroundColor: Colors.grey,
                                             ));
                                           }
          
          
                                           Navigator.pop(context);
                                         },
                                         title: "# Bars for Section",
                                         hintText: "ex. 32",
                                         controller: controller,
                                         confirmText: "Done",
                                         type: TextInputType.number,
                                       );
                                     },
                                     textWidget: BodyText("Bars: ${section.bars.toString()}")
                                 ),
                                 const SizedBox(width: 20,),
                                 //Region: updating tempo
                                 AppTextButton(
                                     onPressed: () {
                                       songsProvider.setSelectedSectionId(section.sectionId);
                                       TextEditingController controller = TextEditingController(text: section.tempo.toString());
                                       showInputDialogue(context: context,
                                         handleSubmit: () {
                                           String text = controller.text.trim();
                                           if (text.isNumeric) {
                                             int tempo = int.parse(text);
                                             tempo = tempo.clamp(20, 400);
                                             songsProvider.updateFieldInSection(
                                                 songId: songsProvider.selectedSongId,
                                                 sectionId: songsProvider.selectedSectionId,
                                                 toUpdate: "tempo",
                                                 value: tempo);
                                           } else {
                                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                               content: const BodyText(
                                                   "Input can only contain numbers"),
                                               showCloseIcon: true,
                                               duration: const Duration(seconds: 2),
                                               backgroundColor: Colors.grey,
                                             ));
                                           }
          
          
                                           Navigator.pop(context);
                                         },
                                         title: "Set new tempo",
                                         hintText: "ex. 120",
                                         controller: controller,
                                         confirmText: "Done",
                                         type: TextInputType.number,
                                       );
                                     },
                                     textWidget: BodyText("Tempo: ${section.tempo.toString()}")
                                 ),
                               ],
                             ),
          
                             //Region: subdivision and meter
          
          
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               spacing: 30,
                               children: [
                                 //Region: subdivision selector
                                 SelectorButton(
                                   onPress: (){
                                     songsProvider.setSelectedSectionId(section.sectionId);
                                     songsProvider.toggleSubdivisionPopup();
                                    },
                                   content: FilteredImage(assetPath: section.subdivision.imagePath, width: 30, height: 30, color: AppColors.text)
                                ),
                                 //Region: meter selector
                                 SelectorButton(
                                   onPress: () {
                                     songsProvider.setSelectedSectionId(section.sectionId);
                                     songsProvider.toggleMeterPopup();
                                     },
                                   content: BodyText("${section.meter[0]} / ${section.meter[1]}")
                                 ),
                               ],
                             ),
          
                             const SizedBox(height: 16,),
                             SingleChildScrollView(
                               padding: EdgeInsets.all(0),
                               scrollDirection: Axis.horizontal,
                               child: AccentSelector(height: 70, totalWidth: 350, sectionId: section.sectionId,),
                             )
          
          
                           ],
                         ),
                       )
                    ],
                  ),
               ),
              ),
          
          
              if (songsProvider.isMeterPopupVisible)
                GestureDetector(
                  onTap: () {
                    songsProvider.toggleMeterPopup();
                  },
                  child: Container(
                    color: AppColors.shadowColor, // Semi-transparent background
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
          
                if (songsProvider.isSubdivisionPopupVisible)
                  GestureDetector(
                    onTap: () {
                      songsProvider.toggleSubdivisionPopup();
                    },
                    child: Container(
                       color: AppColors.shadowColor, // Semi-transparent background
                       width: double.infinity,
                       height: double.infinity,
                     ),
                   ),
          
              MeterSelector(),
              SubdivisionSelector()
            ]
           )
        );
      },
    );
  }
}
