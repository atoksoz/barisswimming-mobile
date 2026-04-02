class SeatModel {
  final int id;
  final String name;
  final int order;
  final bool is_reserved;

  SeatModel({
    required this.id,
    required this.name,
    required this.order,
    required this.is_reserved,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'],
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      is_reserved: json['is_reserved'] ?? false,
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final int order;
  final List<SeatModel> seats;

  LocationModel({
    required this.id,
    required this.name,
    required this.order,
    required this.seats,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      seats: (json['seats'] as List<dynamic>?)
              ?.map((e) => SeatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MemberSelectionModel {
  final int id;
  final int? selected_seat_id;
  final String? selected_seat_name;

  MemberSelectionModel({
    required this.id,
    this.selected_seat_id,
    this.selected_seat_name,
  });

  factory MemberSelectionModel.fromJson(Map<String, dynamic> json) {
    return MemberSelectionModel(
      id: json['id'],
      selected_seat_id: json['selected_seat_id'],
      selected_seat_name: json['selected_seat_name'],
    );
  }
}

class SeatSelectionModel {
  final List<LocationModel> locations;
  final List<int> reserved_seat_ids;
  final List<int> nod;
  final MemberSelectionModel? member;

  SeatSelectionModel({
    required this.locations,
    required this.reserved_seat_ids,
    required this.nod,
    this.member,
  });

  factory SeatSelectionModel.fromJson(Map<String, dynamic> json) {
    return SeatSelectionModel(
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reserved_seat_ids: (json['reserved_seat_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      nod: (json['nod'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      member: json['member'] != null
          ? MemberSelectionModel.fromJson(json['member'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GroupLessonModel {
  final int id;
  final String service_plan_name;
  final int person_limit;
  final int remain_limit;
  final int day_of_week;
  final String time;
  final String employee_name;
  final int person_count;
  final bool member_registered;
  final String plan_date;
  final String plan_datetime;
  final String day_name;
  final bool can_today_resarvation;
  final String explanation;
  final String enable_time;
  final String? employee_image;
  final bool enable_seat_selection;
  final bool is_paid;
  final bool only_purchased_members_can_register;
  final String? services_id;
  final int min_limit;
  final SeatSelectionModel? seat_selection;

  GroupLessonModel({
    required this.id,
    required this.service_plan_name,
    required this.person_limit,
    required this.remain_limit,
    required this.day_of_week,
    required this.time,
    required this.employee_name,
    required this.person_count,
    required this.member_registered,
    required this.plan_date,
    required this.plan_datetime,
    required this.day_name,
    required this.can_today_resarvation,
    required this.enable_time,
    required this.explanation,
    required this.employee_image,
    required this.enable_seat_selection,
    required this.is_paid,
    required this.only_purchased_members_can_register,
    required this.min_limit,
    this.services_id,
    this.seat_selection,
  });

  factory GroupLessonModel.fromJson(Map<String, dynamic> json) {
    return GroupLessonModel(
        id: json["id"],
        service_plan_name: json['service_plan_name'],
        person_limit: json['person_limit'],
        remain_limit: json["remain_limit"],
        day_of_week: json['day_of_week'],
        time: json['time'],
        employee_name: json['employee_name'],
        person_count: json['person_count'],
        member_registered: (json['member_registered'] == true || json['member_registered'] == 1 || json['member_registered'] == "true"),
        plan_date: json["plan_date"],
        plan_datetime: json["plan_datetime"] ?? "",
        day_name: json["day_name"],
        explanation: json["explanation"] ?? "",
        enable_time: json["enable_time"] ?? "",
        employee_image: json["employee_image"]?.toString() ?? "",
        can_today_resarvation: json["can_today_resarvation"] ?? false,
        enable_seat_selection: json["enable_seat_selection"] ?? false,
        is_paid: json["is_paid"] ?? false,
        only_purchased_members_can_register: (json['only_purchased_members_can_register'] == true || json['only_purchased_members_can_register'] == 1 || json['only_purchased_members_can_register'] == "true" || json['only_purchased_members_can_register'] == "1"),
        services_id: json["services_id"]?.toString(),
        min_limit: json["min_limit"] ?? 0,
        seat_selection: json["seat_selection"] != null
            ? SeatSelectionModel.fromJson(json["seat_selection"] as Map<String, dynamic>)
            : null);
  }
}
