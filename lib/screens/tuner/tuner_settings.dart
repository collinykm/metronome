import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:metronome_app/components/app_icon_button.dart";
import "package:metronome_app/components/popup_container.dart";
import "package:metronome_app/components/subscript.dart";
import "package:metronome_app/components/superscript.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";
import "package:provider/provider.dart";


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
        child: Superscript(
          text: noteList[i%12][0],
          superscript: noteList[i%12].length > 1 ? noteList[i%12][1] : "",
          style: TextStyles.title.copyWith(

          )
        ),

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
         height: 520,
         width: MediaQuery.of(context).size.width * 0.8,
         widget: Container(
           padding: EdgeInsets.all(20),
           decoration: BoxDecoration(
               color: AppColors.background,
               borderRadius: BorderRadius.circular(20)
           ),
           child: SingleChildScrollView(
             padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom, // shift above keyboard
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 //Region: Display Section
                 TitleText("Display"),
                 RadioGroup<bool>(
                   onChanged: (value) {
                     tunerProvider.toggleFlats();
                   },
                   groupValue: tunerProvider.useFlats,
                   child: Column(
                     children: [
                       ListTile(
                         title: BodyText("Flats: C D♭ D E♭ ..."),
                         trailing: Radio<bool>(
                           value: true,
                           activeColor: AppColors.accent2,
                         ),
                       ),
                       ListTile(
                         title: BodyText("Sharps: C C♯ D D♯ ..."),
                         trailing: Radio<bool>(
                           value: false,
                           activeColor: AppColors.accent2,
                         ),
                       ),
                     ],
                   )
                 ),
             
                 Divider(),
                 //Region: Transpose section
                 const SizedBox(height: 10,),
                 TitleText("Transpose"),
                 const SizedBox(height: 10,),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     BodyText("Your Instrument's C"),
                     AppIcons.arrowDownUp(),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         BodyText("Concert  "),
                         DropdownButton(
                             value: tunerProvider.transposeSemitones,
                             items: generateMenuList(),
                             onChanged: (semiTones) {
                               tunerProvider.updateTransposeSemitones(semiTones!);
                             },
                           dropdownColor: AppColors.background,
                         ),
                       ],
                     ),
                   ],
                 ),
             
             
             
                 Divider(),
                 //Note: A4 frequency
                 Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Subscript(text: "A", subscript: "4", style: TextStyles.title),
                     TitleText(" Frequency")
                   ],
                 ),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     const SizedBox(height: 10,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         AppIconButton(onPressed: () {
                            HapticFeedback.lightImpact();
                            tunerProvider.updateA4Freq(tunerProvider.A4_FREQ - 1);
                           },
                           icon: AppIcons.minus()
                         ),
                         Text("${tunerProvider.A4_FREQ}Hz", style: TextStyles.body.copyWith(fontSize: 18),),
                         AppIconButton(onPressed: () { HapticFeedback.lightImpact();tunerProvider.updateA4Freq(tunerProvider.A4_FREQ + 1);}, icon: AppIcons.plus()),
                       ],
                     ),
                     const SizedBox(height: 20,),



                     /*
                     SizedBox(
                       width: 30,
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

                      */
                     TextButton(
                       style: TextButton.styleFrom(
                         backgroundColor: Colors.grey.shade300,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadiusGeometry.circular(12)
                         )

                       ),
                       onPressed: () {tunerProvider.updateA4Freq(440);},
                       child: Text(
                         "Reset to default 440Hz",
                         style: TextStyles.body.copyWith(fontSize: 12),
                       )
                     )
                   ],
                 ),

             
             
               ],
             ),
           ),
         ),
       );
      }
    );
  }
}
