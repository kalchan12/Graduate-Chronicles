import 'dart:io';
import 'package:flutter/services.dart';

class BertTokenizer {
  final Map<String, int> vocab;
  final bool lowerCase;

  BertTokenizer({required this.vocab, this.lowerCase = true});

  /// Loads vocab from assets
  static Future<BertTokenizer> fromAsset(
    String path, {
    bool lowerCase = true,
  }) async {
    final vocabStr = await rootBundle.loadString(path);
    final vocabList = vocabStr.split('\n');
    final vocabMap = <String, int>{};
    for (int i = 0; i < vocabList.length; i++) {
      if (vocabList[i].trim().isNotEmpty) {
        vocabMap[vocabList[i].trim()] = i;
      }
    }
    return BertTokenizer(vocab: vocabMap, lowerCase: lowerCase);
  }

  List<int> tokenize(String text, {int maxLen = 128}) {
    // 1. Basic cleaning
    String normalized = text;
    if (lowerCase) normalized = normalized.toLowerCase();

    // 2. Split by whitespace
    final words = normalized.split(RegExp(r'\s+'));
    final tokens = <String>[];

    // 3. WordPiece Tokenization
    for (var word in words) {
      if (word.isEmpty) continue;

      bool found = false;
      int start = 0;
      while (start < word.length) {
        int end = word.length;
        String? curSubStr;

        while (start < end) {
          String subStr = word.substring(start, end);
          if (start > 0) subStr = '##$subStr';

          if (vocab.containsKey(subStr)) {
            curSubStr = subStr;
            break;
          }
          end--;
        }

        if (curSubStr == null) {
          tokens.add('[UNK]');
          found = false;
          break;
        } else {
          tokens.add(curSubStr);
          start = end;
          found = true;
        }
      }
    }

    // 4. Convert to IDs
    final ids = <int>[];
    ids.add(vocab['[CLS]'] ?? 101); // Default CLS

    for (var token in tokens) {
      if (ids.length >= maxLen - 1) break; // Reserve space for SEP
      ids.add(vocab[token] ?? (vocab['[UNK]'] ?? 100));
    }

    ids.add(vocab['[SEP]'] ?? 102); // Default SEP

    // 5. Pad
    while (ids.length < maxLen) {
      ids.add(0); // PAD
    }

    return ids;
  }
}
