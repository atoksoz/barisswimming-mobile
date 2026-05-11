import '../../data/model/member_model.dart';
import '../../core/enums/application_type.dart';
import '../../core/enums/mobile_user_type.dart';

class UserConfig {
  final String memberId;
  final String name;
  final String phone;
  final String email;
  final String birthday;
  final int gender;
  final String token;
  final String imageUrl;
  final String thumbImageUrl;
  final String firmUuid;
  /// IAM / use-token çıktısı `host`; önbellekte tutulur (`ApplicationType` çıkarımı için).
  final String tenantHostUrl;
  final MobileUserType userType;
  final ApplicationType applicationType;

  UserConfig({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.email,
    required this.birthday,
    required this.gender,
    required this.token,
    required this.imageUrl,
    required this.thumbImageUrl,
    required this.firmUuid,
    this.tenantHostUrl = '',
    this.userType = MobileUserType.member,
    this.applicationType = ApplicationType.openGym,
  });

  factory UserConfig.fromMemberModel({
    required MemberModel member,
    required String token,
    required String firmUuid,
  }) {
    return UserConfig(
      memberId: member.id,
      name: member.name,
      phone: member.phone,
      email: member.email ?? '',
      birthday: member.birthday,
      gender: int.tryParse(member.gender) ?? 0,
      token: token,
      imageUrl: member.imageUrl,
      thumbImageUrl: member.thumbImageUrl,
      firmUuid: firmUuid,
      userType: MobileUserType.member,
    );
  }

  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
      memberId: (map["member_id"] ?? "").toString(),
      name: map["name"] ?? "",
      phone: map["phone"] ?? "",
      email: map["email"] ?? "",
      birthday: map["birthday"] ?? "",
      gender: int.tryParse(map["gender"]?.toString() ?? "0") ?? 0,
      token: map["token"] ?? "",
      imageUrl: map["image_url"] ?? "",
      thumbImageUrl: map["thumb_image_url"] ?? "",
      firmUuid: map["firm_uuid"] ?? "",
      tenantHostUrl: map["host"]?.toString() ?? '',
      userType: MobileUserType.fromDynamic(map["user_type"]),
      applicationType: ApplicationType.fromUserPayloadMap(map),
    );
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    return UserConfig(
      memberId: json["member_id"] ?? '',
      name: json["name"] ?? '',
      phone: json["phone"] ?? '',
      email: json["email"] ?? '',
      birthday: json["birthday"] ?? '',
      gender: int.tryParse(json["gender"]?.toString() ?? '0') ?? 0,
      token: json["token"] ?? '',
      imageUrl: json["image_url"] ?? '',
      thumbImageUrl: json["thumb_image_url"] ?? '',
      firmUuid: json["firm_uuid"] ?? '',
      tenantHostUrl: m["host"]?.toString() ?? '',
      userType: MobileUserType.fromDynamic(json["user_type"]),
      applicationType: ApplicationType.fromUserPayloadMap(m),
    );
  }

  Map<String, dynamic> toJson() => {
        "member_id": memberId,
        "name": name,
        "phone": phone,
        "email": email,
        "birthday": birthday,
        "gender": gender,
        "token": token,
        "image_url": imageUrl,
        "thumb_image_url": thumbImageUrl,
        "firm_uuid": firmUuid,
        "host": tenantHostUrl,
        "user_type": userType.value,
        "application_type": applicationType.value,
      };

  factory UserConfig.empty() => UserConfig(
        memberId: '',
        name: '',
        phone: '',
        email: '',
        birthday: '',
        gender: 0,
        token: '',
        imageUrl: '',
        thumbImageUrl: '',
        firmUuid: '',
        tenantHostUrl: '',
        userType: MobileUserType.member,
        applicationType: ApplicationType.openGym,
      );

  UserConfig copyWith({
    String? memberId,
    String? name,
    String? phone,
    String? email,
    String? birthday,
    int? gender,
    String? token,
    String? imageUrl,
    String? thumbImageUrl,
    String? firmUuid,
    String? tenantHostUrl,
    MobileUserType? userType,
    ApplicationType? applicationType,
  }) {
    return UserConfig(
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      token: token ?? this.token,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
      firmUuid: firmUuid ?? this.firmUuid,
      tenantHostUrl: tenantHostUrl ?? this.tenantHostUrl,
      userType: userType ?? this.userType,
      applicationType: applicationType ?? this.applicationType,
    );
  }
}
