import 'package:intl/intl.dart';

class MeasurementAttachment {
  final String path;
  final String? mimeType;
  final String? name;

  MeasurementAttachment({
    required this.path,
    this.mimeType,
    this.name,
  });

  factory MeasurementAttachment.fromJson(Map<String, dynamic> json) {
    return MeasurementAttachment(
      path: json['file_path'] ??
          json['path'] ??
          json['url'] ??
          json['file_url'] ??
          '',
      mimeType: json['mime_type'] ?? json['mimeType'],
      name: json['name'] ?? json['file_name'] ?? json["original_name"],
    );
  }

  bool get isImage {
    final pathLower = path.toLowerCase();
    final mimeLower = (mimeType ?? '').toLowerCase();
    return pathLower.endsWith('.jpg') ||
        pathLower.endsWith('.jpeg') ||
        pathLower.endsWith('.png') ||
        mimeLower.startsWith('image/');
  }

  bool get isPdf {
    final pathLower = path.toLowerCase();
    final mimeLower = (mimeType ?? '').toLowerCase();
    return pathLower.endsWith('.pdf') || mimeLower == 'application/pdf';
  }
}

class MeasurementModel {
  final int id;
  final int userId;
  final String size;
  final String bodyWeight;
  final String arm;
  final String chest;
  final String shoulder;
  final String stomach;
  final String createdAt;
  final String file;
  final List<MeasurementAttachment> attachments;

  MeasurementModel({
    required this.id,
    required this.userId,
    required this.size,
    required this.bodyWeight,
    required this.arm,
    required this.chest,
    required this.shoulder,
    required this.stomach,
    required this.createdAt,
    required this.file,
    List<MeasurementAttachment>? attachments,
  }) : attachments = attachments ?? <MeasurementAttachment>[];

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    List<MeasurementAttachment> attachmentsList = [];

    // attachments array'i varsa parse et
    try {
      if (json['attachments'] != null && json['attachments'] is List) {
        final attachmentsRaw = json['attachments'] as List;
        attachmentsList = attachmentsRaw
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) {
              try {
                return MeasurementAttachment.fromJson(
                    item as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing attachment: $e');
                return null;
              }
            })
            .whereType<MeasurementAttachment>()
            .toList();
      }
    } catch (e) {
      print('Error parsing attachments list: $e');
      attachmentsList = [];
    }

    // Eski format: file string'i varsa ve attachments boşsa, onu da ekle
    try {
      if (json['file'] != null &&
          json['file'].toString().isNotEmpty &&
          attachmentsList.isEmpty) {
        final fileStr = json['file'].toString();
        // Eğer file bir URL veya path ise, PDF olarak ekle
        if (fileStr.toLowerCase().endsWith('.pdf') ||
            fileStr.startsWith('http')) {
          attachmentsList.add(MeasurementAttachment(
            path: fileStr,
            mimeType: 'application/pdf',
          ));
        }
      }
    } catch (e) {
      print('Error parsing file field: $e');
    }

    return MeasurementModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      size: (json['size'] ?? '').toString(),
      bodyWeight: (json['body_weight'] ?? '').toString(),
      arm: (json['arm'] ?? '').toString(),
      chest: (json['chest'] ?? '').toString(),
      shoulder: (json['shoulder'] ?? '').toString(),
      stomach: (json['stomach'] ?? '').toString(),
      createdAt: json['created_at'] ?? '',
      file: (json['file'] ?? '').toString(),
      attachments: attachmentsList,
    );
  }

  // Helper methods
  bool get hasMeasurementDetails {
    try {
      final sizeStr = size.toString();
      final bodyWeightStr = bodyWeight.toString();
      final armStr = arm.toString();
      final chestStr = chest.toString();
      final shoulderStr = shoulder.toString();
      final stomachStr = stomach.toString();

      return (sizeStr.isNotEmpty &&
              sizeStr != '0' &&
              sizeStr != '0.0' &&
              sizeStr != 'null') ||
          (bodyWeightStr.isNotEmpty &&
              bodyWeightStr != '0' &&
              bodyWeightStr != '0.0' &&
              bodyWeightStr != 'null') ||
          (armStr.isNotEmpty &&
              armStr != '0' &&
              armStr != '0.0' &&
              armStr != 'null') ||
          (chestStr.isNotEmpty &&
              chestStr != '0' &&
              chestStr != '0.0' &&
              chestStr != 'null') ||
          (shoulderStr.isNotEmpty &&
              shoulderStr != '0' &&
              shoulderStr != '0.0' &&
              shoulderStr != 'null') ||
          (stomachStr.isNotEmpty &&
              stomachStr != '0' &&
              stomachStr != '0.0' &&
              stomachStr != 'null');
    } catch (e) {
      // Hata durumunda false döndür
      return false;
    }
  }

  List<MeasurementAttachment> get pdfAttachments {
    try {
      return attachments.where((a) => a.isPdf).toList();
    } catch (e) {
      print('Error getting pdfAttachments: $e');
      return <MeasurementAttachment>[];
    }
  }

  List<MeasurementAttachment> get imageAttachments {
    try {
      return attachments.where((a) => a.isImage).toList();
    } catch (e) {
      print('Error getting imageAttachments: $e');
      return <MeasurementAttachment>[];
    }
  }

  String get formattedDate {
    try {
      final inputFormat = DateFormat("HH:mm:ss dd-MM-yyyy");
      final outputFormat = DateFormat("dd/MM/yyyy");
      final date = inputFormat.parse(createdAt);
      return outputFormat.format(date);
    } catch (e) {
      return createdAt; // parse edemezse orijinali döner
    }
  }
}
