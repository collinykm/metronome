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

    super.initState();
  }

  @override
  void dispose() {
    tunerProvider.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TunerProvider>(
        builder: (context, tunerProvider, child) {
          if (!tunerProvider.isSounding) {
            return const Text('—');
          }
          return Column(
            children: [
              Text('${tunerProvider.getTuningArray()}',
                  style: const TextStyle(fontSize: 48)),
              Text('${tunerProvider.frequency!.toStringAsFixed(2)} Hz'),
            ],
          );
        }
      )
    );
  }
}
