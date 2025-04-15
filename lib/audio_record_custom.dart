import 'dart:io';

import 'package:audio_play_custom/service/supabase/connect.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderCustom {
  final _recorder = AudioRecorder();
  String? recordedFilePath;
  String? audioUrl;

  Future<void> startRecording() async {
    // Đảm bảo recorder được phép
    if (await _recorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      recordedFilePath = path;

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      print("Recording started: $path");
    }
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      print("Recording saved to: $path");
      recordedFilePath = path;
      final result = await SupabaseConnect.uploadFile(
        File(path).readAsBytesSync(),
        'test',
        'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      print("Upload file result: $result");
      audioUrl = 'https://srffmbooioioziyhdrcr.supabase.co/storage/v1/object/public/' + result;
    } else {
      print("Recording was not saved.");
    }
  }

  Future dispose() async {
    await _recorder.dispose();
  }

  Future<bool> isRecording() => _recorder.isRecording();
}
