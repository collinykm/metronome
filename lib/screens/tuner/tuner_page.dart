import "package:flutter/material.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:provider/provider.dart";

import "../../theme/typography.dart";

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {

  late TunerProvider tunerProvider;

  @override
  void initState() {
    tunerProvider = Provider.of<TunerProvider>(context, listen: false);
    tunerProvider.initializeRecorder();
    tunerProvider.initializeWindowing();
    super.initState();
  }

  @override
  void dispose() {
    tunerProvider.stopRecording();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TunerProvider>(
        builder: (context, tunerProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyText(
                  'Current Pitch:'
                ),
                BodyText(
                  '${tunerProvider.smoothedPitch.toStringAsFixed(1)} Hz',
                ),

                BodyText(
                  'Current Note:',
                ),
                BodyText(
                  '${tunerProvider.getNote()}',
                ),


                BodyText(
                  'Debug Info:'
                ),
                BodyText(
                  tunerProvider.debugInfo,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: tunerProvider.isInitialized
                      ? (tunerProvider.isRecording ? tunerProvider.stopRecording : tunerProvider.startRecording)
                      : null,
                  child: BodyText(tunerProvider.isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}
