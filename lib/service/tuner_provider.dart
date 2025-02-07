import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';


class TunerProvider with ChangeNotifier{
  late FlutterSoundRecorder _recorder;
  StreamSubscription? _recordingDataSubscription;
  late StreamController<Uint8List> _streamController;

  bool _isRecording = false;
  bool _isInitialized = false;
  double _currentPitch = 0.0;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  double get currentPitch => _currentPitch;


  // Enhanced configuration
  final int windowSize = 4096;  // Increased for better low frequency resolution
  final double threshold = 0.20;
  final int overlapSize = 2048;  // 50% overlap
  List<double> _audioBuffer = [];

  // Relaxed thresholds
  final double minConfidence = 0.3;
  final double minSignalPower = 0.0001;

  final int fftSize = 2048;


  // Advanced smoothing configuration
  final int smoothingBufferSize = 7;
  List<double> frequencyBuffer = [];
  double _smoothedPitch = 0.0;
  double get smoothedPitch => _smoothedPitch;

  // Signal quality metrics
  double _confidence = 0.0;
  double _signalPower = 0.0;


  // Pre-calculated window coefficients
  late List<double> _hanningWindow;

  // Pre-emphasis filter coefficient
  final double preEmphasis = 0.97;




  void initializeWindowing() {
    _hanningWindow = List.filled(windowSize, 0);
    for (int i = 0; i < windowSize; i++) {
      _hanningWindow[i] = 0.5 * (1 - cos(2 * pi * i / (windowSize - 1)));
    }
  }

  Future<void> initializeRecorder() async {
    _recorder = FlutterSoundRecorder(logLevel: Level.off);



    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 30));


    _isInitialized = true;
    notifyListeners();

  }

  Future<void> startRecording() async {
    if (!_isInitialized) return;

    _streamController = StreamController<Uint8List>();
    _streamController.stream.listen((data) {
      _processAudioData(data);
    });

    try {
      await _recorder.startRecorder(
        toStream: _streamController.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 44100,
      );
      _isRecording = true;
      _audioBuffer.clear();
      frequencyBuffer.clear();
      notifyListeners();

    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        await _streamController.close();
      }

      _isRecording = false;
      _currentPitch = 0.0;
      _smoothedPitch = 0.0;
      _confidence = 0.0;
      _signalPower = 0.0;
      _audioBuffer.clear();
      frequencyBuffer.clear();


    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  List<double> _applyPreEmphasis(List<double> input) {
    List<double> output = List.filled(input.length, 0);
    output[0] = input[0];
    for (int i = 1; i < input.length; i++) {
      output[i] = input[i] - preEmphasis * input[i - 1];
    }
    return output;
  }

  double _calculateSignalPower(List<double> buffer) {
    double sum = 0;
    for (double sample in buffer) {
      sum += sample * sample;
    }
    return sum / buffer.length;
  }



  // Debug variables
  String _debugInfo = '';
  String get debugInfo => _debugInfo;

  double _detectPitch(List<double> buffer) {
    if (buffer.length < windowSize) return 0.0;

    _signalPower = _calculateSignalPower(buffer);

    if (_signalPower < minSignalPower) {
      _debugInfo = 'Signal too weak: $_signalPower';
      _confidence = 0.0;
      return 0.0;
    }

    // Step 1: Enhanced autocorrelation for low frequencies
    List<double> r = List.filled(windowSize ~/ 2, 0);
    double r0 = 0;

    // Calculate zero-lag autocorrelation with DC removal
    double mean = 0.0;
    for (int i = 0; i < windowSize; i++) {
      mean += buffer[i];
    }
    mean /= windowSize;

    for (int i = 0; i < windowSize; i++) {
      double centered = buffer[i] - mean;
      r0 += centered * centered;
    }

    if (r0 == 0) {
      _debugInfo = 'Zero autocorrelation';
      return 0.0;
    }

    // Calculate autocorrelation with DC removal
    for (int tau = 0; tau < windowSize ~/ 2; tau++) {
      double sum = 0;
      for (int i = 0; i < windowSize - tau; i++) {
        double centered1 = buffer[i] - mean;
        double centered2 = buffer[i + tau] - mean;
        sum += centered1 * centered2;
      }
      r[tau] = sum / r0;
    }

    // Step 2: Modified difference function
    List<double> diff = List.filled(windowSize ~/ 2, 0);
    List<double> cmnd = List.filled(windowSize ~/ 2, 0);

    diff[0] = 1.0;
    cmnd[0] = 1.0;
    double runningSum = 0;

    for (int tau = 1; tau < windowSize ~/ 2; tau++) {
      diff[tau] = 1.0 - r[tau];
      runningSum += diff[tau];
      cmnd[tau] = diff[tau] * tau / (runningSum + double.minPositive);
    }

    // Step 3: Multi-stage minimum search
    int minTau = 0;
    double minValue = double.infinity;

    // Extended search range for lower frequencies (40-1000 Hz)
    int minIndex = (44100 ~/ 1000).clamp(0, windowSize ~/ 2);  // ~44 samples
    int maxIndex = (44100 ~/ 40).clamp(0, windowSize ~/ 2);    // ~1102 samples

    // First pass: Find all potential valleys
    List<Map<String, dynamic>> valleys = [];

    for (int tau = minIndex; tau < maxIndex; tau++) {
      if (cmnd[tau] < threshold) {
        if (tau > 0 && tau < windowSize ~/ 2 - 1) {
          if (cmnd[tau] < cmnd[tau - 1] && cmnd[tau] < cmnd[tau + 1]) {
            valleys.add({
              'tau': tau,
              'value': cmnd[tau],
              'freq': 44100.0 / tau
            });
          }
        }
      }
    }

    // Second pass: Score valleys based on multiple criteria
    if (valleys.isNotEmpty) {
      double bestScore = double.negativeInfinity;
      Map<String, dynamic> bestValley = valleys[0];

      for (var valley in valleys) {
        double freq = valley['freq'];
        double value = valley['value'];
        int tau = valley['tau'];

        // Score based on:
        // 1. Valley depth (lower is better)
        // 2. Neighborhood clarity (difference from neighbors)
        // 3. Sub-harmonics presence
        double depthScore = 1.0 - value;
        double clarityScore = (cmnd[tau - 1] + cmnd[tau + 1]) / 2 - value;

        // Check for sub-harmonics
        double subHarmonicPenalty = 0.0;
        for (double div = 2; div <= 4; div++) {
          int subTau = (tau * div).round();
          if (subTau < windowSize ~/ 2) {
            if (cmnd[subTau] < value * 1.5) {
              subHarmonicPenalty += 0.2;
            }
          }
        }

        double score = depthScore + clarityScore - subHarmonicPenalty;

        if (score > bestScore) {
          bestScore = score;
          bestValley = valley;
        }
      }

      minTau = bestValley['tau'];
      minValue = bestValley['value'];
    }

    if (minTau == 0 || minValue == double.infinity) {
      _debugInfo = 'No valid minimum found';
      _confidence = 0.0;
      return 0.0;
    }

    // Parabolic interpolation for refined frequency
    double alpha = cmnd[minTau - 1];
    double beta = cmnd[minTau];
    double gamma = cmnd[minTau + 1];
    double refinedTau = minTau + 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);

    double frequency = 44100.0 / refinedTau;
    _confidence = 1.0 - minValue;

    _debugInfo = 'f: ${frequency.toStringAsFixed(1)} Hz, '
        'c: ${(_confidence * 100).toStringAsFixed(1)}%, '
        'v: ${minValue.toStringAsFixed(3)}';

    return frequency;
  }

  void _processAudioData(Uint8List data) {
    // Convert bytes to audio samples
    List<double> samples = [];
    double maxAmp = 0.0;

    for (int i = 0; i < data.length ~/ 2; i++) {
      int sample = (data[2 * i + 1] << 8) | data[2 * i];
      if (sample > 32767) sample -= 65536;
      double normalizedSample = sample / 32768.0;
      maxAmp = max(maxAmp, normalizedSample.abs());
      samples.add(normalizedSample);
    }

    // Debug input signal

    _audioBuffer.addAll(samples);

    // Process when we have enough data
    while (_audioBuffer.length >= windowSize) {
      // Create windowed buffer
      List<double> windowedBuffer = List.filled(windowSize, 0);
      for (int i = 0; i < windowSize; i++) {
        windowedBuffer[i] = _audioBuffer[i] * (0.5 - 0.5 * cos(2 * pi * i / (windowSize - 1)));
      }

      double frequency = _detectPitch(windowedBuffer);

      if (frequency > 0) {  // Removed confidence check for testing

        _currentPitch = frequency;
        _smoothedPitch = frequency;  // Simplified smoothing for testing

        notifyListeners();
      }

      _audioBuffer.removeRange(0, windowSize - overlapSize);
    }
  }



  String getNote() {
    if (_smoothedPitch <= 0) return '-';

    final notes = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];
    final a4 = 440.0;
    final a4Index = notes.indexOf('A');

    final halfSteps = (12 * log(_smoothedPitch / a4) / log(2)).round();
    final octave = ((halfSteps + a4Index) / 12).floor() + 4;
    final noteIndex = (halfSteps + a4Index) % 12;

    return notes[noteIndex] + octave.toString();
  }


}