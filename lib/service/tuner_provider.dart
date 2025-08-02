import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

/// TunerProvider — keeps LAST valid reading when silent.
class TunerProvider extends ChangeNotifier {
  // ── Public API ────────────────────────────────────────────────────────────
  double? get frequency => _currentFrequency == 0 ? null : _currentFrequency;
  String? get note      => _currentNote.isEmpty ? null : _currentNote;
  int?    get octave    => _currentNote.isEmpty ? null : _currentOctave;
  int?    get cents     => _currentNote.isEmpty ? null : _currentCents;
  bool    get isInitialized => _isInitialized;
  bool    get isSounding    => _isSounding;

  /// Returns `[note, octave, cents]` or `null` if we’ve *never* detected anything.
  List<dynamic>? getTuningArray() =>
      _currentNote.isEmpty ? null : [_currentNote, _currentOctave, _currentCents];

  // ── Init / dispose ───────────────────────────────────────────────────────
  Future<void> initializeRecorder({int sampleRate = 44100, int bufferSize = 2048}) async {
    if (_isInitialized) return;
    _detector   = PitchDetector(audioSampleRate: sampleRate.toDouble(), bufferSize: bufferSize);
    await _audioCapture.init();
    await _audioCapture.start(_onAudioData, _onAudioError, sampleRate: sampleRate, bufferSize: bufferSize);
    _isInitialized = true;
    notifyListeners();
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

  static const double _volumeThreshold = 0.005;
  static const double _smoothing       = 0.25;
  static const double _snapCents       = 60;
  static const double _minFreq         = 30.0;
  static const double _maxFreq         = 4000.0;

  bool   _isInitialized = false;
  bool   _isSounding    = false;


  double _currentFrequency = 0.0;
  String _currentNote      = '';
  int    _currentOctave    = 0;
  int    _currentCents     = 0;
  double _lastSmoothedFreq = 0.0;

  // ── Audio callbacks ──────────────────────────────────────────────────────
  void _onAudioError(Object e) => debugPrint('[Tuner] error: $e');

  Future<void> _onAudioData(dynamic obj) async {
    final Float64List buf = obj is Float64List
        ? obj
        : Float64List.fromList((obj as Float32List).map((e) => e.toDouble()).toList());

    final rms = _rootMeanSquare(buf);
    final bool soundingNow = rms > _volumeThreshold;

    if (!soundingNow) {
      // just update flag & quit; keep last good reading
      if (_isSounding) {
        _isSounding = false;
        notifyListeners();
      }
      return;
    }
    _isSounding = true;

    // YIN pitch detect
    final result = await _detector.getPitchFromFloatBuffer(buf.toList());
    if (!result.pitched) return;
    final double f = result.pitch;
    if (f < _minFreq || f > _maxFreq) return;

    // Smoothing
    double smoothed;
    if (_lastSmoothedFreq == 0) {
      smoothed = f;
    } else {
      final double centsJump = (1200 * (log(f / _lastSmoothedFreq) / ln2)).abs();
      smoothed = centsJump > _snapCents ? f : _lerp(_lastSmoothedFreq, f, _smoothing);
    }
    _lastSmoothedFreq = smoothed;

    // Note mapping
    final _NoteData nd = _freqToNoteAndCents(smoothed);

    final bool changed = (smoothed - _currentFrequency).abs() > 0.5 || nd.note != _currentNote;
    if (changed) {
      _currentFrequency = smoothed;
      _currentNote      = nd.note;
      _currentOctave    = nd.octave;
      _currentCents     = nd.cents.round();
      notifyListeners();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  static double _rootMeanSquare(Float64List buf) {
    double s = 0; for (final v in buf) s += v * v; return sqrt(s / buf.length);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;


  bool useFlats = true;
  List<String> get noteNames {
    if (useFlats) {
      return ['C','D♭','D','E♭', "E", 'F','G♭','G','A♭','A','B♭', "B"];
    } else {
      return ['C','C♯','D','D♯','E','F','F♯','G','G♯','A','A♯','B'];
    }
  }

  int _A4_FREQ = 440;
  void updateA4Freq(int freq){
    _A4_FREQ = freq;
  }

  _NoteData _freqToNoteAndCents(double f) {
    final double midiExact = 69 + 12 * (log(f / 440) / ln2);
    final int    midiInt   = midiExact.round();
    final String noteName  = noteNames[midiInt % 12];
    final int    octave    = (midiInt ~/ 12) - 1;
    final double refFreq   = _A4_FREQ.toDouble() * pow(2, (midiInt - 69) / 12);
    final double cents     = 1200 * (log(f / refFreq) / ln2);
    return _NoteData(note: noteName, octave: octave, cents: cents);
  }
}

class _NoteData {
  final String note; final int octave; final double cents;
  const _NoteData({required this.note, required this.octave, required this.cents});
}
