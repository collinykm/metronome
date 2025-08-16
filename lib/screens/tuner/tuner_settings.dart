import "package:flutter/material.dart";
import "package:metronome_app/components/popup_container.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";
import "package:provider/provider.dart";
import "package:string_validator/string_validator.dart";

class TunerSettings extends StatefulWidget {
  const TunerSettings({super.key});

  @override
  State<TunerSettings> createState() => _TunerSettingsState();
}

class _TunerSettingsState extends State<TunerSettings> {

  List<DropdownMenuItem<int>> generateMenuList() {
    List<DropdownMenuItem<int>> menuItems = [];
    List<String> noteList = Provider.of<TunerProvider>(context, listen: false).noteNames;
    for (int i = -7; i < 5; i++) {
      DropdownMenuItem<int> item = DropdownMenuItem(
        value: i,
        child: BodyText(noteList[i%12])
      );
      menuItems.add(item);
    }
    return menuItems;

  }

  late TextEditingController a4FreqInput;
  @override
  void initState() {
    a4FreqInput = TextEditingController(text: "${Provider.of<TunerProvider>(context, listen: false).A4_FREQ}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<TunerProvider>(
      builder: (context, tunerProvider, child) {
        if (a4FreqInput.text != "${tunerProvider.A4_FREQ}") {
          a4FreqInput.text = "${tunerProvider.A4_FREQ}";
        }
       return PopupContainer(
         visible: tunerProvider.settingsVisible,
         height: 400,
         width: 280,
         widget: Container(
           width: 280,
           height: 600,
           padding: EdgeInsets.all(20),
           decoration: BoxDecoration(
               color: AppColors.background,
               borderRadius: BorderRadius.circular(12)
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               TitleText("Display"),

               ListTile(
                 title: BodyText("Flats: C D♭ D E♭ ..."),
                 trailing: Radio<bool>(
                   value: true,
                   groupValue: tunerProvider.useFlats,
                   onChanged: (value) {
                     tunerProvider.toggleFlats();
                   },
                 ),
               ),
               ListTile(
                 title: BodyText("Sharps: C C♯ D D♯ ..."),
                 trailing: Radio<bool>(
                   value: false,
                   groupValue: tunerProvider.useFlats,
                   onChanged: (value) {
                     tunerProvider.toggleFlats();
                   },
                 ),
               ),
               Divider(),
               //Note: Transpose section
               TitleText("Transpose"),
               Row(
                 children: [
                   Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       BodyText("C"),
                       Text("on your instrument", style: TextStyles.body.copyWith(fontSize: 12))
                     ],
                   ),
                   AppIcons.rightArrow(),
                   DropdownButton(
                     value: tunerProvider.transposeSemitones,
                     items: generateMenuList(),
                     onChanged: (semiTones) {
                       tunerProvider.updateTransposeSemitones(semiTones!);
                     }
                   ),
                 ],
               ),
               Divider(),
               //Note: A4 frequency
               Column(
                 children: [
                   Row(
                     children: [
                       BodyText("A4"),
                       AppIcons.equal(),
                       Expanded(
                         child: TextField(
                           controller: a4FreqInput,
                           style: TextStyles.body,
                           keyboardType: TextInputType.number,
                           onChanged: (str) {
                             str = str.trim();
                             if (str.isNumeric) {
                               int freq = int.parse(str);
                               tunerProvider.updateA4Freq(freq);
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                 content: const BodyText(
                                     "Input can only contain numbers"),
                                 showCloseIcon: true,
                                 duration: const Duration(seconds: 2),
                                 backgroundColor: Colors.grey,
                               ));
                             }
                           },
                         ),
                       )
                     ],
                   ),
                   TextButton(
                     style: ButtonStyle(
                       backgroundColor: WidgetStatePropertyAll(Colors.grey.shade500),
                     ),
                     onPressed: () {tunerProvider.updateA4Freq(440);},
                     child: Text(
                       "Reset to default 440Hz",
                       style: TextStyles.body.copyWith(fontSize: 10),
                     )
                 )
                 ],
               )


             ],
           ),
         ),
       );
      }
    );
  }
}
