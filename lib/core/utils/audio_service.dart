import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Manages audio playback with a user-gesture guard required for Web.
///
/// On Web, browser policy blocks audio autoplay until the first user interaction.
/// Call [onUserInteraction] from any user-initiated event before playing audio.
final class AudioService extends ChangeNotifier {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isReady = kIsWeb ? false : true; // Web requires gesture unlock

  bool get isReady => _isReady;

  /// Call once on the first user tap/click anywhere in the app.
  void onUserInteraction() {
    if (!_isReady) {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> playAsset(String assetPath) async {
    if (!_isReady) return;
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (_) {
      // Audio failure is non-fatal — UI shows muted-speaker icon
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
