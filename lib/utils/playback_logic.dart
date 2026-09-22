class EndingSkipGuard {
  Duration _lastPosition = Duration.zero;

  bool shouldSkip({
    required bool playing,
    required Duration? duration,
    required Duration skipEnd,
    required Duration position,
  }) {
    if (!playing || duration == null || skipEnd <= Duration.zero) {
      _lastPosition = position;
      return false;
    }
    if (position <= duration - skipEnd) {
      _lastPosition = position;
      return false;
    }
    if (position - _lastPosition < skipEnd) {
      _lastPosition = position;
      return true;
    }
    return false;
  }
}
