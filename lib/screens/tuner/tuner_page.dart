import "package:flutter/material.dart";
import "package:metronome_app/screens/tuner/tuner_gauge.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:metronome_app/theme/colors.dart";
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
    tunerProvider.disposeRecorder();
    super.dispose();
  }

  List<dynamic> get tuningOutputArray {
    print("within tunerPage: ${tunerProvider.tuningOutputArray}");
    return tunerProvider.tuningOutputArray;
  }
  
  @override
  Widget build(BuildContext context) {
    final List<dynamic> tuningOutputArray = context.select<TunerProvider, List<dynamic>?>((p) => p.tuningOutputArray) ?? [];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40,),
              TunerGauge(),
              const SizedBox(height: 40,),
              Text("${tuningOutputArray[0]}${tuningOutputArray[1]}")
        
            ],
          ),
        ),
      ),
    );
  }
}
