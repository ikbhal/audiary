import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(AudioDiaryApp());
}

class AudioDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioDiaryScreen(),
    );
  }
}

class AudioDiaryScreen extends StatefulWidget {
  @override
  _AudioDiaryScreenState createState() => _AudioDiaryScreenState();
}

class _AudioDiaryScreenState extends State<AudioDiaryScreen> {
  List<File> _diaryEntries = [];
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    _initializeDiaryEntries();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeDiaryEntries() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDir.listSync();

    setState(() {
      _diaryEntries = files.whereType<File>().toList();
    });
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
        // Directory appDir = await getApplicationDocumentsDirectory();
        // String filePath = '${appDir.path}/${DateTime.now().toString()}.aac';
      }
    } catch (e) {
      print("Error during recording of audio is $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      print("Error during stopping of recording is $e");
    }
  }

  Future<void> _playAudio(String filePath) async {
    // Add logic to handle playing state, UI changes, etc.

  }

  Future<void> _deleteAudio(String filePath) async {
    File audioFile = File(filePath);
    await audioFile.delete();

    await _initializeDiaryEntries();
  }

  // isPlaying ? stopPlaying : startPlaying
  Future<void> startPlaying() async {
    try {
      Source urlSource = UrlSource(audioPath);
      audioPlayer.play(urlSource);
    } catch (e) {
      print("Unable to start playing due to $e");
    }
  }

  Future<void> stopPlaying() async {
    try {
      audioPlayer.stop();
    } catch (e) {
      print("Unable to stop playing due to $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Diary'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: isRecording ? stopRecording : startRecording,
      //   child: isRecording ? const Text("stop"): const Icon(Icons.mic),
      // ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: isRecording ? stopRecording : startRecording,
            child: Icon(isRecording ? Icons.stop : Icons.mic),
          ),
          SizedBox(height: 16),
          if (!isRecording && audioPath != null)
            ElevatedButton(
              onPressed: isPlaying ? stopPlaying : startPlaying,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            )
        ],
      ),
      body: ListView.builder(
        itemCount: _diaryEntries.length,
        itemBuilder: (context, index) {
          File diaryEntry = _diaryEntries[index];

          return ListTile(
            title: Text(
              '${diaryEntry.path.split('/').last}',
            ),
            subtitle: Text(
              '${diaryEntry.lastModifiedSync().toString()}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _playAudio(diaryEntry.path),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAudio(diaryEntry.path),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
