class MemberRegisterFileModel {
  final String id;
  final String fileType;
  final String fileName;
  final String fileSize;
  final String mimeType;
  final String fileUrl;
  final String downloadUrl;
  final String createdAt;

  MemberRegisterFileModel({
    required this.id,
    required this.fileType,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.fileUrl,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory MemberRegisterFileModel.fromJson(Map<String, dynamic> json) {
    return MemberRegisterFileModel(
      id: json['id']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileSize: json['file_size']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  // Getter for display label
  String get displayLabel {
    switch (fileType) {
      case 'request_form':
        return 'Talep Formu';
      case 'contract':
        return 'Sözleşme';
      default:
        return fileName;
    }
  }
}
