import 'dart:async';
import 'package:flutter/material.dart';

class SessionClock extends StatefulWidget {
  final ValueChanged<String>? onTimeChanged;
  final VoidCallback? onStop;


  const SessionClock({super.key, this.onTimeChanged, this.onStop});

  @override
  State<SessionClock> createState() => SessionClockState();
}

class SessionClockState extends State<SessionClock> {
  //Define a Stopwatch to make the clock work, and a Timer to update the UI every second.
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //Method to start the stopwatch and the timer that updates the UI.
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          widget.onTimeChanged?.call(_formattedTime);
        });
      });
    }
  }

  //Method to pause the stopwatch and cancel the timer.
  void _pauseStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;
      setState(() {
        widget.onTimeChanged?.call(_formattedTime);
      });
    }
  }


  //Method to stop the stopwatch and cancel the timer.
  void _stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
    _timer?.cancel();
    _timer = null;
    widget.onTimeChanged?.call(_formattedTime);
    widget.onStop?.call();
    setState(() {});
  }

  void resetStopwatch() {
    _stopwatch.reset();
    _timer?.cancel();
    _timer = null;
    widget.onTimeChanged?.call(_formattedTime);
    setState(() {});
  }

  //Boolean getter to check if the stopwatch is at zero.
  bool get _isAtZero => _stopwatch.elapsedMilliseconds == 0;

  //String getter to format the elapsed time in the format HH:MM:SS.
  String get _formattedTime {
    final elapsed = _stopwatch.elapsed;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
  

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final textColor = isDark ? Colors.grey[100] : Colors.grey[900];

    return Row(
      children: [
        Expanded(
          //Paddings and formatting for the container that holds the clock and the buttons.
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: backgroundColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _formattedTime,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: _stopwatch.isRunning
                                ? null
                                : _startStopwatch,
                            icon: const Icon(Icons.play_arrow),
                            iconSize: 35,
                          ),
                          const SizedBox(width: 20),
                          IconButton.filled(
                            onPressed: (_isAtZero || !_stopwatch.isRunning)
                                ? null
                                : _pauseStopwatch,
                            icon: const Icon(Icons.pause),
                            iconSize: 35,
                          ),
                          const SizedBox(width: 16),
                          IconButton.filled(
                            onPressed: _isAtZero ? null : _stopStopwatch,
                            icon: const Icon(Icons.stop),
                            iconSize: 35,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
