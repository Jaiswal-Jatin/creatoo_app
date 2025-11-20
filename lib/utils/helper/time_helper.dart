import 'dart:async';

class TimerHelper {
  late Timer _timer;
  late Duration _duration;
  late Function(int) _onTimerTick;

  void startTimer(Duration duration, Function(int) onTimerTick) {
    _duration = duration;
    _onTimerTick = onTimerTick;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration -= Duration(seconds: 1);
        _onTimerTick(_duration.inSeconds);
      } else {
        _timer.cancel();
      }
    });
  }

  void cancelTimer() {
    _timer.cancel();
  }
}