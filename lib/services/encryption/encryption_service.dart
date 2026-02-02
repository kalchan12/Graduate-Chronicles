import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionService {
  late final Key _key;
  // Use a fixed initialization vector? No, we use random IV per message.

  EncryptionService() {
    _initKey();
  }

  void _initKey() {
    try {
      // Attempt to load key from .env
      String? keyString = dotenv.env['ENCRYPTION_KEY'];

      // Fallback or Validate
      if (keyString == null || keyString.isEmpty) {
        print(
          '⚠️ EncryptionService: No ENCRYPTION_KEY found in .env, using fallback.',
        );
        keyString = '12345678901234567890123456789012'; // 32 chars
      }

      // Ensure exact 32 bytes for AES-256
      if (keyString.length < 32) {
        keyString = keyString.padRight(32, '#');
      } else if (keyString.length > 32) {
        keyString = keyString.substring(0, 32);
      }

      _key = Key.fromUtf8(keyString);
      print('🔐 EncryptionService initialized (Key length: ${_key.length})');
    } catch (e) {
      print('❌ EncryptionService Initialization Error: $e');
      // Fallback to a safe default to prevent app crash
      _key = Key.fromUtf8('12345678901234567890123456789012');
    }
  }

  /// Encrypts plain text using AES-256.
  String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;

    try {
      final iv = IV.fromLength(16); // Generate random IV
      final encrypter = Encrypter(
        AES(_key, mode: AESMode.cbc),
      ); // Explicit mode
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      print('❌ Encryption Error: $e');
      return plainText; // Fail open (save plaintext) rather than crashing
    }
  }

  /// Decrypts text.
  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        // Not in our format, return as-is (legacy plaintext)
        return encryptedText;
      }

      final iv = IV.fromBase64(parts[0]);
      final encryptedContent = parts[1];

      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      return encrypter.decrypt64(encryptedContent, iv: iv);
    } catch (e) {
      print(
        '⚠️ Decryption Failed for message [${encryptedText.substring(0, 10)}...]: $e',
      );
      // Return the original text so user sees *something* (e.g. "iv:ciphertext")
      // checking if it looks like our format
      if (encryptedText.contains(':')) {
        return 'Decryption Error';
      }
      return encryptedText;
    }
  }
}
