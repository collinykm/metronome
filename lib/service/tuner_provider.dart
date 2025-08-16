import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:flutter_sound/flutter_sound.dart';



/// TunerProvider — keeps last reading when silent and guards callbacks
/// after dispose so you won’t hit “used after being disposed”.
class TunerProvider with ChangeNotifier {
  // ───────────────────────── State exposed to UI ──────────────────────────
  double? get frequency => _currentNote.isEmpty ? null : _currentFrequency;
  String? get note      => _currentNote.isEmpty ? null : _currentNote;
  int?    get octave    => _currentNote.isEmpty ? null : _currentOctave;
  int?    get cents     => _currentNote.isEmpty ? null : _currentCents;
  bool    get isInitialized => _isInitialized;
  bool    get isSounding    => _isSounding;
  List<dynamic> get tuningOutputArray => _currentNote.isEmpty ? ["-", "-", "-"] : [_currentNote, _currentOctave, _currentCents];
  //note, octave, cents


  //Region Things I need to worry about
  bool _useFlats = true;
  bool get useFlats => _useFlats;
  void toggleFlats() {
    _useFlats = !_useFlats;
    notifyListeners();
  }
  List<String> get noteNames {
    if (_useFlats) {
      return ['C','D♭','D','E♭', "E", 'F','G♭','G','A♭','A','B♭', "B"];
    } else {
      return ['C','C♯','D','D♯','E','F','F♯','G','G♯','A','A♯','B'];
    }
  }

  int _A4_FREQ = 440;
  int get A4_FREQ => _A4_FREQ;
  void updateA4Freq(int freq){
    _A4_FREQ = freq;
    notifyListeners();
  }
  int transposeSemitones = 0;
  void updateTransposeSemitones(int semitones) {
    transposeSemitones += semitones;
    notifyListeners();
  }
  //for example Bb would be -2, Eb would be 3

  bool _settingsVisible = false;
  bool get settingsVisible => _settingsVisible;
  void toggleSettingsVisibility() {_settingsVisible = !_settingsVisible; notifyListeners();}




  bool _refNoteVisible = false;
  bool get refNoteVisible => _refNoteVisible;
  void toggleRefNoteVisibility() {_refNoteVisible = !_refNoteVisible; notifyListeners();}

  final _soundPlayer = FlutterSoundPlayer();
  bool isPlaying = false;
  final List _selectedNote = [9, 4];
  //Note: index 0 represents index in notes list (or how many half notes), in this case 9 = A; index 1 represents octave
  List get selectedNote => _selectedNote;
  void updateSelectedNote(int noteIndex) {
    _selectedNote[0] = noteIndex;
    int numSemiFromC1 = (selectedNote[1] - 1) * 12 + selectedNote[0];
    double freq = 440.0 * pow(2, (numSemiFromC1 - 45) / 12);
    print(freq);
    notifyListeners();
  }
  void updateSelectedNoteOctave(int octave) {
    octave = octave.clamp(1, 8);
    _selectedNote[1] = octave;
    notifyListeners();
  }

  final MethodChannel methodChannel = MethodChannel('metronome_method_channel');


  void initializePlayer() {

  }
  StreamController<Uint8List>? _controller;
  Future<void> playReferenceFreq() async {
    //getting the hertz
    int numSemiFromC1 = (selectedNote[1] - 1) * 12 + selectedNote[0];
    double freq = 440.0 * pow(2, (numSemiFromC1 - 45) / 12);

    isPlaying = true;
    notifyListeners();


    methodChannel.invokeMethod("playRefNote", freq);


  }

  Future<void> pausePlayer() async {
    isPlaying = false;
    notifyListeners();
    methodChannel.invokeMethod("pauseRefNote");
  }

  Future<void> disposePlayer() async {
    isPlaying = false;
    if (_soundPlayer.isOpen()) {
      if (_soundPlayer.isPlaying) await _soundPlayer.stopPlayer();
      await _soundPlayer.closePlayer();
    }
  }









  // ───────────────────── Initialisation / teardown ────────────────────────
  Future<void> initializeRecorder({int sampleRate = 44100, int bufferSize = 2048}) async {
    final st = await Permission.microphone.request();
    if (!st.isGranted) return; // don’t start recorder
    if (_isInitialized) return;
    _disposed = false;
    _detector   = PitchDetector(audioSampleRate: sampleRate.toDouble(), bufferSize: bufferSize);
    await _audioCapture.init();
    await _audioCapture.start(_onAudioData, _onAudioError, sampleRate: sampleRate, bufferSize: bufferSize);
    _isInitialized = true;
    notifyListeners();
  }

  void disposeRecorder() {
    _disposed = true;
    _audioCapture.stop();
    _isInitialized = false;
    _streamSub?.cancel();
  }

  // ─────────────────────────── Internal fields ────────────────────────────
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
  bool   _disposed      = false; // guard flag


  double _currentFrequency = 0.0;
  String _currentNote      = '';
  int    _currentOctave    = 0;
  int    _currentCents     = 0;
  double _lastSmoothedFreq = 0.0;

  // ───────────────────────────── Callbacks ────────────────────────────────
  void _onAudioError(Object e) {
    if (!_disposed) debugPrint('[Tuner] error: $e');
  }

  Future<void> _onAudioData(dynamic obj) async {
    if (_disposed) return; // ignore stray mic events after dispose

    final Float64List buf = obj is Float64List
        ? obj
        : Float64List.fromList((obj as Float32List).map((e) => e.toDouble()).toList());

    final rms = _rootMeanSquare(buf);
    final bool soundingNow = rms > _volumeThreshold;

    if (!soundingNow) {
      if (_isSounding && !_disposed) {
        _isSounding = false;
        notifyListeners();
      }
      return;
    }
    _isSounding = true;

    final result = await _detector.getPitchFromFloatBuffer(buf.toList());
    if (!result.pitched) return;
    final double f = result.pitch;
    if (f < _minFreq || f > _maxFreq) return;

    double smoothed;
    if (_lastSmoothedFreq == 0) {
      smoothed = f;
    } else {
      final double centsJump = (1200 * (log(f / _lastSmoothedFreq) / ln2)).abs();
      smoothed = centsJump > _snapCents ? f : _lerp(_lastSmoothedFreq, f, _smoothing);
    }
    _lastSmoothedFreq = smoothed;

    final _NoteData nd = _freqToNoteAndCents(smoothed);

    final bool changed =
        (smoothed - _currentFrequency).abs() > 0.5 || nd.note != _currentNote;
    if (changed && !_disposed) {
      _currentFrequency = smoothed;
      _currentNote      = nd.note;
      _currentOctave    = nd.octave;
      _currentCents     = nd.cents.round();
      notifyListeners();
    }
  }



  // ──────────────────────────── Utilities ─────────────────────────────────
  static double _rootMeanSquare(Float64List buf) {
    double s = 0; for (final v in buf) s += v * v; return sqrt(s / buf.length);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;


  _NoteData _freqToNoteAndCents(double f) {
    final double midiExact = 69 + 12 * (log(f / 440) / ln2);
    final int    midiInt   = midiExact.round();
    //For reference, C4 has a midiInt of 60. this means C0 has a midiInt of 12, which matches with the octave var. to transpose, subtract the transposition
    final int transposedNoteIndex = midiInt - transposeSemitones;
    final String noteName  = noteNames[transposedNoteIndex % 12];
    final int    octave    = (transposedNoteIndex ~/ 12) - 1;
    final double refFreq   = _A4_FREQ.toDouble() * pow(2, (midiInt - 69) / 12);
    final double cents     = 1200 * (log(f / refFreq) / ln2);
    return _NoteData(note: noteName, octave: octave, cents: cents);
  }


}

class _NoteData {
  final String note; final int octave; final double cents;
  const _NoteData({required this.note, required this.octave, required this.cents});
}
