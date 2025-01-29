import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:provider/provider.dart";

class AccentSelector extends StatefulWidget {
  const AccentSelector({super.key});


  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {



  @override
  Widget build(BuildContext context) {
    final metronome = Provider.of<MetronomeProvider>(context, listen: false);


    double screenWidth = MediaQuery.of(context).size.width;
    double accentSelectorWidth = (screenWidth - 2*30 - (metronome.accentsList.length - 1) * 20) / metronome.accentsList.length;
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return Consumer<MetronomeProvider>(
      builder: (context, metronome, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < metronome.accentsList.length; i++)
              Container(
                width: accentSelectorWidth,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {metronome.updateAccent(i);},
                  child: changeIcon(metronome.accentsList[i]),
                ),
              ),
          ],

        );
      },

    );
  }

  Widget changeIcon(int accent) {
    switch (accent) {
      case 0:
        return Icon(Icons.exposure_zero); // Square icon
      case 1:
        return Icon(Icons.looks_one_rounded); // Triangle icon
      case 2:
        return Icon(Icons.looks_two_rounded); // Circle icon
      case 3:
        return Icon(Icons.three_g_mobiledata); // Star icon
      default:
        return Icon(Icons.error); // Fallback icon
    }
  }
}
