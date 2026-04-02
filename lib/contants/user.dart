class User {
  final String id;
  final String name;
  final String card_number;
  User({required this.id, required this.name, required this.card_number});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'], name: json['name'], card_number: json['card_number']);
  }

  User.fromMap(
      Map map) // This Function helps to convert our Map into our User Object
      : this.id = map["id"],
        this.name = map["name"],
        this.card_number = map["card_number"];

  Map toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": this.id,
      "name": this.name,
      "card_number": this.card_number,
    };
  }

// static Map<String, dynamic> toMap(User user) => {
//       'id': user.id,
//       'rating': user.name,
//       'card_number': user.card_number,
//     };
//
// static String encode(List<User> musics) => json.encode(
//       musics.map<Map<String, dynamic>>((user) => User.toMap(user)).toList(),
//     );
//
// static List<User> decode(String users) =>
//     (json.decode(users) as List<dynamic>)
//         .map<User>((item) => User.fromJson(item))
//         .toList();
}
