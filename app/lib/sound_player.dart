import 'dart:io';

import 'package:flutter/services.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

class SoundPlayer {
  AudioPlayer audioPlugin = AudioPlayer();
  final List<String> soundList;
  List<String> uriList;

  void init() {
    _init();
  }

  SoundPlayer(this.soundList);

  Future<Null> _init() async {
    for (var i = 0; i < soundList.length; i++) {
      String sound = soundList[i];
      final ByteData data = await rootBundle.load(sound);
      var tempDir = await getTemporaryDirectory();
      File file = File("$tempDir.path}/{i}.mp3");
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      uriList.add(file.uri.toString());
    }
  }

  void play(int index) {
    if (uriList[index] != null) {
      audioPlugin.play(uriList[index]);
    }
  }
}
