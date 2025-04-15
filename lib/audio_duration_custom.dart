import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart'; // dùng để combine streams

class JustAudioWidget extends StatefulWidget {
  final String url;

  const JustAudioWidget({super.key, required this.url});

  @override
  State<JustAudioWidget> createState() => _JustAudioWidgetState();
}

class _JustAudioWidgetState extends State<JustAudioWidget> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.url);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            final position = positionData?.position ?? Duration.zero;
            final duration = positionData?.duration ?? Duration.zero;

            return Column(
              children: [
                Slider(
                  value: position.inSeconds.toDouble().clamp(
                    0,
                    duration.inSeconds.toDouble(),
                  ),
                  max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) {
                    _player.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ],
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final playing = playerState?.playing ?? false;
            final processingState = playerState?.processingState;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const CircularProgressIndicator();
            } else if (playing) {
              return IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => _player.pause(),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _player.play(),
              );
            }
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
