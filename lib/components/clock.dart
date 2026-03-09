import 'dart:async';
import 'package:flutter/material.dart';

class SessionClock extends StatefulWidget {
  const SessionClock({super.key});

  @override
  State<SessionClock> createState() => _SessionClockState();
}

class _SessionClockState extends State<SessionClock> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  bool get _running => _stopwatch.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _toggleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopTicker();
    } else {
      _stopwatch.start();
      _startTicker();
    }
    setState(() {});
  }

  void _reset() {
    _stopwatch.reset();
    setState(() {});
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    if (hours > 0) {
      return '\$hours:\$minutes:\$seconds.\$millis';
    }
    return '\$minutes:\$seconds.\$millis';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _format(elapsed),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _toggleStartStop,
            child: Text(_running ? 'Stop' : 'Start'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _reset,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}