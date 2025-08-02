import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';

/// A [ChangeNotifier] backend for a real‑time tuner.
///
/// * Call [initializeRecorder] once (e.g. in your widget’s `initState`).
/// * Read `frequency`, `note`, `octave`, `cents` or use [getTuningArray].
class TunerProvider extends ChangeNotifier {
  // ── Public API ────────────────────────────────────────────────────────────
  double? get frequency => _isSounding ? _currentFrequency : null;
  String? get note      => _isSounding ? _currentNote      : null;
  int?    get octave    => _isSounding ? _currentOctave    : null;
  int?    get cents     => _isSounding ? _currentCents     : null; // signed
  bool    get isInitialized => _isInitialized;
  bool    get isSounding    => _isSounding;

  /// Returns `[noteName, octave, cents]`, e.g. `['C#', 6, -20]` (flat) or
  /// `['A', 4, 5]` (sharp); `null` when silent.
  List<dynamic>? getTuningArray() =>
      _isSounding ? [_currentNote, _currentOctave, _currentCents] : null;

  /// Initialise microphone capture & pitch detection. Safe to call multiple times.
  Future<void> initializeRecorder({
    int sampleRate = 44100,
    int bufferSize = 2048,
  }) async {
    if (_isInitialized) return;

    _sampleRate = sampleRate;
    _bufferSize = bufferSize;
    _detector   = PitchDetector(
      audioSampleRate: sampleRate.toDouble(),
      bufferSize: bufferSize,
    );

    await _audioCapture.init();
    await _audioCapture.start(
      _onAudioData,
      _onAudioError,
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    _isInitialized = true;
    notifyListeners();
    print('[Tuner] Recorder initialised (sr=$sampleRate, buf=$bufferSize)');
  }

  @override
  void dispose() {
    _audioCapture.stop();
    _streamSub?.cancel();
    super.dispose();
  }

  // ── Implementation details ───────────────────────────────────────────────
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late PitchDetector _detector;
  StreamSubscription? _streamSub;

  // Tunables
  static const double _volumeThreshold = 0.005; // RMS below = silence
  static const double _smoothing       = 0.25;  // 0‑1  (higher = snappier)
  static const double _snapCents       = 60;    // >60¢ jump = snap to new freq
  static const double _minFreq         = 30.0;
  static const double _maxFreq         = 4000.0;

  // State
  bool   _isInitialized    = false;
  bool   _isSounding       = false;
  late int _sampleRate;
  late int _bufferSize;

  double _currentFrequency = 0.0;
  String _currentNote      = '';
  int    _currentOctave    = 0;
  int    _currentCents     = 0; // signed (‑50 .. +50 typical)
  double _lastSmoothedFreq = 0.0;

  void _onAudioError(Object e) => print('[Tuner] Audio error: $e');

  Future<void> _onAudioData(dynamic obj) async {
    // flutter_audio_capture streams Float64List (iOS) or Float32List (Android)
    final Float64List buf64 = obj is Float64List
        ? obj
        : Float64List.fromList((obj as Float32List).map((e) => e.toDouble()).toList());

    // Quick RMS gate
    final rms = _rootMeanSquare(buf64);
    _isSounding = rms > _volumeThreshold;

    if (!_isSounding) {
      if (_currentFrequency != 0) {
        _currentFrequency = 0;
        notifyListeners();
      }
      return;
    }

    // Pitch detection (YIN)
    final PitchDetectorResult result = await _detector.getPitchFromFloatBuffer(buf64.toList());
    if (!result.pitched) return;

    final double detectedFreq = result.pitch;
    if (detectedFreq < _minFreq || detectedFreq > _maxFreq) return;

    // ── Adaptive smoothing ──────────────────────────────────────────────
    double smoothed;
    if (_lastSmoothedFreq == 0) {
      smoothed = detectedFreq;
    } else {
      final double centsDiff =
      (1200 * (log(detectedFreq / _lastSmoothedFreq) / ln2)).abs();
      smoothed = centsDiff > _snapCents
          ? detectedFreq
          : _lerp(_lastSmoothedFreq, detectedFreq, _smoothing);
    }
    _lastSmoothedFreq = smoothed;

    // Note mapping & cents offset
    final _NoteData nd = _freqToNoteAndCents(smoothed);

    // Update state if display‑worthy change
    final bool changed =
        (smoothed - _currentFrequency).abs() > 0.5 || nd.note != _currentNote;
    if (changed) {
      _currentFrequency = smoothed;
      _currentNote      = nd.note;
      _currentOctave    = nd.octave;
      _currentCents     = nd.cents.round();
      notifyListeners();
      print('[Tuner] ${_currentNote}${_currentOctave} ' // eg. C#6
          '${_currentCents >= 0 ? '+' : ''}${_currentCents}¢ ' // +5¢ / ‑12¢
          '(${_currentFrequency.toStringAsFixed(2)} Hz)');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static double _rootMeanSquare(Float64List buf) {
    double sumSq = 0;
    for (final v in buf) sumSq += v * v;
    return sqrt(sumSq / buf.length);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  _NoteData _freqToNoteAndCents(double freq) {
    // Fractional MIDI note where A4=440 Hz → 69
    final double midiExact = 69 + 12 * (log(freq / 440) / ln2);
    final int    midiInt   = midiExact.round();

    final String noteName  = _noteNames[midiInt % 12];
    final int    octave    = (midiInt ~/ 12) - 1;

    // Reference frequency of that MIDI note
    final double refFreq   = 440.0 * pow(2, (midiInt - 69) / 12);
    final double cents     = 1200 * (log(freq / refFreq) / ln2);

    return _NoteData(note: noteName, octave: octave, cents: cents);
  }
}

class _NoteData {
  final String note;
  final int    octave;
  final double cents; // signed
  const _NoteData({required this.note, required this.octave, required this.cents});
}
