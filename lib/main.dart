import 'package:audio_play_custom/audio_duration_custom.dart';
import 'package:audio_play_custom/audio_record_custom.dart';
import 'package:audio_play_custom/constant.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioRecorderCustom audioRecorderCustom = AudioRecorderCustom();
  bool isRecord = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Ghi âm'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await audioRecorderCustom.startRecording();
                    setState(() {
                      isRecord = true;
                    });
                  },
                  child: const Text('Ghi âm'),
                ),
                Text(isRecord ? 'Đang ghi âm' : 'Đã dừng ghi âm'),
                ElevatedButton(
                  onPressed: () async {
                    await audioRecorderCustom.stopRecording();
                    setState(() {
                      isRecord = false;
                    });
                  },
                  child: const Text('Dừng ghi âm'),
                ),
              ],
            ),
            if (audioRecorderCustom.audioUrl != null)
              JustAudioWidget(url: audioRecorderCustom.recordedFilePath!),
          ],
        ),
      ),
    );
  }
}
