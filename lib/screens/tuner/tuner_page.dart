import "package:flutter/material.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:provider/provider.dart";

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
                Text(
                  'Current Pitch:',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  '${tunerProvider.smoothedPitch.toStringAsFixed(1)} Hz',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),

                Text(
                  'Current Note:',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  '${tunerProvider.getNote()}',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),


                Text(
                  'Debug Info:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  tunerProvider.debugInfo,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: tunerProvider.isInitialized
                      ? (tunerProvider.isRecording ? tunerProvider.stopRecording : tunerProvider.startRecording)
                      : null,
                  child: Text(tunerProvider.isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}
