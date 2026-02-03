import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'bert_tokenizer.dart';

class MLService {
  Interpreter? _interpreter;
  BertTokenizer? _tokenizer;
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> init() async {
    if (_isReady) return;

    try {
      final options = InterpreterOptions();
      // Attempt to load model
      try {
        _interpreter = await Interpreter.fromAsset(
          'assets/tflite/model.tflite',
          options: options,
        );
      } catch (e) {
        print(
          '⚠️ MLService: Model not found. Did you run setup_model.sh? ($e)',
        );
        return;
      }

      // Attempt to load vocab
      try {
        _tokenizer = await BertTokenizer.fromAsset('assets/tflite/vocab.txt');
      } catch (e) {
        print('⚠️ MLService: Vocab not found. ($e)');
        return;
      }

      _isReady = true;
      print('✅ MLService: Initialized successfully.');

      // Log shapes for debug
      if (_interpreter != null) {
        print('Input Tensors: ${_interpreter!.getInputTensors()}');
        print('Output Tensors: ${_interpreter!.getOutputTensor(0).shape}');
      }
    } catch (e) {
      print('❌ MLService Init Error: $e');
    }
  }

  /// Generates a sentence embedding (CLS token) for the given text.
  Future<List<double>?> getEmbedding(String text) async {
    if (!_isReady || _interpreter == null || _tokenizer == null) return null;

    try {
      // 1. Tokenize
      // 128 is standard max length for small models
      final ids = _tokenizer!.tokenize(text, maxLen: 128);

      // 2. Prepare Inputs
      // [1, 128]
      final inputIds = [ids];

      // Attention Mask (1 for real tokens, 0 for pad)
      final attentionMask = [List.filled(128, 0)];
      for (int i = 0; i < 128; i++) {
        // 0 is PAD in BERT
        if (ids[i] != 0) attentionMask[0][i] = 1;
      }

      // Token Type IDs (all 0 for single sentence)
      final tokenTypeIds = [List.filled(128, 0)];

      // Inputs list for Interpreter
      // Most exported BERT models accept inputs in this order:
      // input_ids, attention_mask, token_type_ids
      // But we should verify input tensors count.
      final inputs = [inputIds, attentionMask, tokenTypeIds];

      // 3. Prepare Outputs
      // We expect [1, 128, H] or [1, H].
      // We'll prepare a map for outputs.
      final outputTensor = _interpreter!.getOutputTensor(0);
      final shape = outputTensor.shape; // e.g. [1, 128, 312]

      // If output is 3D [Batch, Seq, Hidden], we need to flatten for buffer?
      // Or simply allocate List<List<List<double>>>?
      // tflite_flutter handles standard lists.

      // Dynamic allocation based on shape
      // We assume Batch=1
      final seqLen = shape[1];
      final hiddenSize = shape[2];

      // Buffer: [1, Seq, Hidden]
      // Initialize with 0.0
      var outputBuffer = List.generate(
        1,
        (_) => List.generate(seqLen, (_) => List.filled(hiddenSize, 0.0)),
      );

      final outputs = {0: outputBuffer};

      // 4. Run Inference
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // 5. Extract Embedding (CLS token at index 0)
      // outputBuffer[0][0] is the [1, Hidden] vector for CLS
      // Note: Some models output pooled [1, Hidden] directly.
      // If shape is [1, Hidden], logic differs.

      List<double> embedding;
      if (shape.length == 2) {
        // [1, Hidden] -> Pooled
        // outputBuffer would be List<List<double>>
        // This cast is tricky with generic Object map.
        // We re-allocate if shape is 2D
        var out2D = List.generate(1, (_) => List.filled(shape[1], 0.0));
        _interpreter!.runForMultipleInputs(inputs, {0: out2D});
        embedding = out2D[0];
      } else {
        // [1, Seq, Hidden] -> Sequence
        // CLS is at seq index 0
        embedding = outputBuffer[0][0];
      }

      return embedding;
    } catch (e) {
      print('❌ Inference Error: $e');
      return null;
    }
  }

  /// Calculates Cosine Similarity between two vectors
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;

    return dot / (sqrt(normA) * sqrt(normB));
  }

  void dispose() {
    _interpreter?.close();
  }
}
