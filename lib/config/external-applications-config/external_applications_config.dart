class ExternalApplicationsConfig {
  final String hamamspaApiUrl;
  final String onlineReservation;
  final String kantincim;
  final String gymTraining;
  final String digitalSignage;
  final String splashScreen;
  final String securityCode;
  final int applicationId;
  final String host;
  final String rta;
  final String apiHamamspaUrl;
  final String potentialCustomer;
  final String gymexxtraApi;

  ExternalApplicationsConfig({
    required this.hamamspaApiUrl,
    required this.onlineReservation,
    required this.kantincim,
    required this.gymTraining,
    required this.digitalSignage,
    required this.splashScreen,
    required this.securityCode,
    required this.applicationId,
    required this.host,
    required this.rta,
    required this.apiHamamspaUrl,
    required this.potentialCustomer,
    required this.gymexxtraApi,
  });

  factory ExternalApplicationsConfig.fromMap(Map<String, dynamic> map) {
    return ExternalApplicationsConfig(
        hamamspaApiUrl: map['hamamspa_api_url'] ?? '',
        onlineReservation: map['online_resarvation'] ?? '',
        kantincim: map['kantincim'] ?? '',
        gymTraining: map['gym_training'] ?? '',
        digitalSignage: map['digital_signage'] ?? '',
        splashScreen: map['splah_screen'] ?? '',
        securityCode: map['security_code'] ?? '',
        applicationId:
            int.tryParse(map["application_id"]?.toString() ?? "0") ?? 0,
        host: map['host'] ?? '',
        rta: map['rta'] ?? '',
        apiHamamspaUrl: map['api_host'] ?? '',
        potentialCustomer: map['potential_customer'] ?? '',
        gymexxtraApi: map['gymexxtra_api'] ?? '');
  }

  factory ExternalApplicationsConfig.fromJson(Map<String, dynamic> json) {
    return ExternalApplicationsConfig(
        hamamspaApiUrl: json['hamamspa_api_url'] ?? '',
        onlineReservation: json['online_resarvation'] ?? '',
        kantincim: json['kantincim'] ?? '',
        gymTraining: json['gym_training'] ?? '',
        digitalSignage: json['digital_signage'] ?? '',
        splashScreen: json['splah_screen'] ?? '',
        securityCode: json['security_code'] ?? '',
        applicationId: json['application_id'] ?? 0,
        host: json['host'] ?? '',
        apiHamamspaUrl: json['api_host'] ?? '',
        rta: json['rta'] ?? '',
        potentialCustomer: json['potential_customer'] ?? '',
        gymexxtraApi: json['gymexxtra_api'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'hamamspa_api_url': hamamspaApiUrl,
      'online_resarvation': onlineReservation,
      'kantincim': kantincim,
      'gym_training': gymTraining,
      'digital_signage': digitalSignage,
      'splah_screen': splashScreen,
      'security_code': securityCode,
      'application_id': applicationId,
      'host': host,
      'rta': rta,
      'api_host': apiHamamspaUrl,
      'potential_customer': potentialCustomer,
      'gymexxtra_api': gymexxtraApi
    };
  }
}
