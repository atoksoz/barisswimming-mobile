import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Image compression and resizing utility using native compression
/// 
/// This utility provides methods to compress and resize images to reduce file size
/// while maintaining reasonable quality. Uses flutter_image_compress for native performance.
class ImageCompressionUtil {
  /// Resize and compress an image if it exceeds the maximum size
  /// 
  /// [imageFile] - The image file to process
  /// [maxSizeMB] - Maximum file size in MB (default: 1 MB)
  /// 
  /// Returns the resized file if compression was needed, or the original file if it's already small enough.
  /// Returns null if an error occurs during processing.
  static Future<File?> resizeImageIfNeeded(
    File imageFile, {
    int maxSizeMB = 1,
  }) async {
    try {
      print('🔄 Resize başladı: ${DateTime.now()}');
      final startTime = DateTime.now();
      
      final fileSizeInBytes = imageFile.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      print('📊 Dosya boyutu: ${fileSizeInMB.toStringAsFixed(2)} MB');

      // Eğer dosya maxSizeMB'dan küçükse direkt döndür
      if (fileSizeInMB <= maxSizeMB) {
        print('✅ Dosya zaten $maxSizeMB MB altında, resize gerekmiyor');
        return imageFile;
      }

      // UI thread'e nefes aldır - işlem öncesi
      await Future.delayed(const Duration(milliseconds: 300));

      print('🖼️ Native image compression başlıyor...');
      final compressStartTime = DateTime.now();
      
      // Dosya boyutuna göre kalite ve boyut parametrelerini ayarla
      int quality;
      int? minWidth;
      int? minHeight;
      
      if (fileSizeInMB > 8) {
        quality = 75;
        minWidth = 1200;
        minHeight = 1200;
      } else if (fileSizeInMB > 5) {
        quality = 80;
        minWidth = 1400;
        minHeight = 1400;
      } else if (fileSizeInMB > 3) {
        quality = 82;
        minWidth = 1500;
        minHeight = 1500;
      } else if (fileSizeInMB > 2) {
        quality = 85;
        minWidth = 1600;
        minHeight = 1600;
      } else {
        quality = 88;
        minWidth = 1800;
        minHeight = 1800;
      }

      // Temporary file path
      final String tempPath = '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Compress using native library (very fast!)
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        tempPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );
      
      print('⏱️ Native compression süresi: ${DateTime.now().difference(compressStartTime).inMilliseconds}ms');

      if (result == null) {
        print('❌ Compression başarısız');
        return null;
      }

      // Convert XFile to File
      File finalFile = File(result.path);
      
      // Check compressed file size
      final compressedSize = await finalFile.length();
      final compressedSizeMB = compressedSize / (1024 * 1024);
      print('📊 Optimize edilmiş dosya boyutu: ${compressedSizeMB.toStringAsFixed(2)} MB');

      // If still too large, try again with more aggressive settings
      if (compressedSizeMB > maxSizeMB && quality > 70) {
        print('🔄 Dosya hala büyük, daha agresif sıkıştırma deneniyor...');
        
        final String tempPath2 = '${imageFile.parent.path}/compressed2_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final result2 = await FlutterImageCompress.compressAndGetFile(
          result.path,
          tempPath2,
          quality: quality - 10,
          minWidth: (minWidth * 0.85).round(),
          minHeight: (minHeight * 0.85).round(),
          format: CompressFormat.jpeg,
        );

        if (result2 != null) {
          // Delete first attempt
          try {
            await finalFile.delete();
          } catch (e) {
            print('⚠️ Temp file delete error: $e');
          }
          
          finalFile = File(result2.path);
          final finalSize = await finalFile.length();
          final finalSizeMB = finalSize / (1024 * 1024);
          print('📊 2. sıkıştırma sonucu: ${finalSizeMB.toStringAsFixed(2)} MB');
        }
      }

      final totalTime = DateTime.now().difference(startTime);
      print('✅ Resize tamamlandı: ${DateTime.now()} - Toplam süre: ${totalTime.inMilliseconds}ms (${totalTime.inSeconds}s)');

      return finalFile;
    } catch (e, stackTrace) {
      print('❌ Image resize error: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }
}
