import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_notifier.dart';
import 'session_state.dart';

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
