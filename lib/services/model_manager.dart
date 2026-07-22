import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ModelManager {
  static const String assetPath = 'assets/models/qwen2.5-1.5b-instruct-q4_k_m.gguf';
  static const String modelFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';

  static Future<String> getModelPath({
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getApplicationSupportDirectory();
    final modelFile = File('${dir.path}/$modelFileName');

    if (await modelFile.exists()) {
      final expectedSize = await _getAssetSize();
      final actualSize = await modelFile.length();
      if (expectedSize != null && actualSize == expectedSize) {
        return modelFile.path;
      }
    }

    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final sink = modelFile.openWrite();

    const chunkSize = 1024 * 1024; // 1MB chunks so we can report progress
    for (int offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = (offset + chunkSize < bytes.length) ? offset + chunkSize : bytes.length;
      sink.add(bytes.sublist(offset, end));
      onProgress?.call(end / bytes.length);
    }

    await sink.flush();
    await sink.close();

    return modelFile.path;
  }

  static Future<int?> _getAssetSize() async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.lengthInBytes;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isModelReady() async {
    final dir = await getApplicationSupportDirectory();
    final modelFile = File('${dir.path}/$modelFileName');
    return modelFile.exists();
  }
}
