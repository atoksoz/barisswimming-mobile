import 'dart:convert';

class TrainerModel {
  final String id;
  final String name;
  final String duty;
  final String image;
  final String explanation;
  final String rate;
  final String instagram;
  final String facebook;
  final String tiktok;
  final String twitter;
  final String youtube;
  final int rate_;

  TrainerModel(
      {required this.id,
      required this.name,
      required this.duty,
      required this.image,
      required this.explanation,
      required this.rate,
      required this.instagram,
      required this.facebook,
      required this.tiktok,
      required this.twitter,
      required this.youtube,
      required this.rate_});

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    var name = json['name'];
    name = jsonDecode('"$name"');
    var rateString = json['rate'] == null ? "0" : json['rate'].toString();
    return TrainerModel(
        rate: rateString,
        instagram: json['instagram'] == null ? "" : json['instagram'],
        facebook: json['facebook'] == null ? "" : json['facebook'],
        tiktok: json['tiktok'] == null ? "" : json['tiktok'],
        twitter: json['twitter'] == null ? "" : json['twitter'],
        youtube: json['youtube'] == null ? "" : json['youtube'],
        id: json["id"].toString(),
        name: jsonDecode('"$name"'), //name,
        duty: json['duty'],
        image: (json['image'] == null ? "" : json['image']),
        explanation: (json['explanation'] == null ? "" : json['explanation']),
        rate_: (double.tryParse(rateString) ?? 0).round() //().round())
        );
  }
}
