class MemberModel {
  final String id;
  final String uuid;
  final String name;
  final String phone;
  final String? email;
  final String birthday;
  final String gender;
  final String imageUrl;
  final String thumbImageUrl;
  final String situation;

  MemberModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.phone,
    this.email,
    required this.birthday,
    required this.gender,
    required this.imageUrl,
    required this.thumbImageUrl,
    required this.situation,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'].toString(),
      uuid: json['uuid'].toString(),
      name: json['name'].toString(),
      phone: json['phone'].toString(),
      email: json['email']?.toString(),
      birthday: json['birthday'].toString(),
      gender: json['gender'].toString(),
      imageUrl: json['image_url'].toString(),
      thumbImageUrl: json['thumb_image_url'].toString(),
      situation: json['situation'].toString(),
    );
  }
}
